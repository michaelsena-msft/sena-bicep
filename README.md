# sena-bicep

AKS + Azure Data Explorer infrastructure with Managed Prometheus for cluster health and ADX-Mon for application observability.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ rg-sena                                                     │
│                                                             │
│  ┌──────────────────┐  ┌───────────────────────────────┐   │
│  │ AKS (rg-sena-aks)│  │ ADX (adxsena)                 │   │
│  │ • Istio + FIPS   │  │ • Metrics DB (31d hot/365d)   │   │
│  │ • 2× D4s_v3      │──│ • Logs DB    (31d hot/365d)   │   │
│  │ • Prometheus DCR  │  │ • Kubelet identity has Admin  │   │
│  └──────────────────┘  └───────────────────────────────┘   │
│           │                                                 │
│  ┌────────┴─────────┐                                      │
│  │ Azure Monitor     │                                      │
│  │ Workspace (AMW)   │                                      │
│  │ • node-exporter   │                                      │
│  │ • kube-state      │                                      │
│  │ • kubelet         │                                      │
│  └──────────────────┘                                      │
└─────────────────────────────────────────────────────────────┘
```

| Layer | What | How |
|---|---|---|
| Cluster health | Node, pod, kubelet metrics | AMW + Prometheus DCR (built-in) |
| App observability | Application metrics + logs | ADX-Mon → ADX cluster |
| App access | Internal hello-world service | Internal LoadBalancer (VNet only) |

## Prerequisites

- Azure CLI with Bicep (`az bicep install`)
- kubectl
- Logged in: `az login`

## 1. Deploy Infrastructure

~15 min (AKS ~8 min, ADX ~12 min, run in parallel).

```bash
az deployment sub create \
  --name sena \
  --location australiaeast \
  --template-file main.bicep \
  --parameters main.bicepparam
```

**Faster iteration** — use these before a full deploy:

```bash
# Syntax + schema check (~10s)
az deployment sub validate \
  --location australiaeast \
  --template-file main.bicep \
  --parameters main.bicepparam

# Dry-run against Azure (~30s, shows what would change)
az deployment sub what-if \
  --location australiaeast \
  --template-file main.bicep \
  --parameters main.bicepparam
```

## 2. Connect to AKS

```bash
az aks get-credentials --resource-group rg-sena --name rg-sena-aks
kubectl get nodes   # 2 nodes, both Ready
```

## 3. Install ADX-Mon

```bash
ADX_URI=$(az deployment sub show --name sena --query properties.outputs.adxClusterUri.value -o tsv)
bash <(curl -s https://raw.githubusercontent.com/Azure/adx-mon/main/build/k8s/bundle.sh)
```

When prompted:

| Prompt | Value |
|---|---|
| ADX Cluster URI | `$ADX_URI` (paste the value) |
| Metrics Database | `Metrics` |
| Logs Database | `Logs` |
| Region | `australiaeast` |

Verify: `kubectl get pods -n adx-mon` — collector (DaemonSet), collector-singleton, and ingestor should be Running.

## 4. Deploy Application

```bash
kubectl apply -f manifests/app.yaml
kubectl get pods -l app=hello-world    # 2 replicas Running
kubectl get svc hello-world            # EXTERNAL-IP is VNet-internal
```

## Outputs

```bash
# Clickable ADX query UI
az deployment sub show --name sena --query properties.outputs.adxWebExplorerUrl.value -o tsv

# ADX cluster URI (for scripts/ADX-Mon)
az deployment sub show --name sena --query properties.outputs.adxClusterUri.value -o tsv
```

## Teardown

```bash
az group delete --name rg-sena --yes --no-wait
```
