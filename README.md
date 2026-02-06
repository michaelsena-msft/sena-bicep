# sena-bicep

AKS + Azure Data Explorer infrastructure with Managed Prometheus for cluster health and ADX-Mon for application observability.

## Architecture

| Module | Resource | Purpose |
|---|---|---|
| resourceGroup | Resource Group | `rg-sena` container |
| aksCluster | AKS (Istio + FIPS) | Kubernetes cluster |
| monitorWorkspace | Azure Monitor Workspace | Prometheus metrics destination |
| prometheusCollection | Data Collection Rule | Cluster health metrics (node-exporter, kube-state-metrics, kubelet) |
| adxCluster | Azure Data Explorer | ADX-Mon metrics + logs backend |

## Prerequisites

- Azure CLI with Bicep (`az bicep install`)
- kubectl
- Azure subscription with Contributor access

## 1. Deploy Infrastructure

```bash
az deployment sub create \
  --name sena \
  --location australiaeast \
  --template-file main.bicep \
  --parameters main.bicepparam
```

## 2. Connect to AKS

```bash
az aks get-credentials --resource-group rg-sena --name rg-sena-aks
```

## 3. Install ADX-Mon

```bash
ADX_URI=$(az deployment sub show --name sena --query properties.outputs.adxClusterUri.value -o tsv)
bash <(curl -s https://raw.githubusercontent.com/Azure/adx-mon/main/build/k8s/bundle.sh)
```

When prompted, provide:
- **ADX Cluster URI:** paste `$ADX_URI`
- **Metrics Database:** `Metrics`
- **Logs Database:** `Logs`
- **Region:** `australiaeast`

## 4. Deploy Application

```bash
kubectl apply -f manifests/app.yaml
```

## Verify

```bash
kubectl get pods                    # hello-world pods running
kubectl get svc hello-world         # EXTERNAL-IP is VNet-internal
```

## Outputs

After deployment, get clickable URLs:

```bash
# ADX Web Explorer (query metrics and logs)
az deployment sub show --name sena --query properties.outputs.adxWebExplorerUrl.value -o tsv

# ADX cluster URI (for scripts)
az deployment sub show --name sena --query properties.outputs.adxClusterUri.value -o tsv
```

## Validate (optional)

```bash
az deployment sub validate \
  --location australiaeast \
  --template-file main.bicep \
  --parameters main.bicepparam
```
