# AKS with Managed Prometheus, Grafana & Istio

Bicep deployment for a production-ready AKS cluster in Australia East.

## Resources Deployed

| Resource | Name Pattern | Location |
|----------|--------------|----------|
| Resource Group | `rg-{workload}-env-aue` | Australia East |
| AKS Cluster | `aks-{workload}-env-aue` | Australia East |
| Azure Monitor Workspace | `amw-{workload}-env-aue` | Australia East |
| Managed Grafana | `grafana-{workload}-env-aue` | Australia East |

## Features

- **FIPS Compliance**: Node pools use FIPS 140-2 validated cryptographic modules
- **Managed Prometheus**: Platform health metrics enabled
- **Managed Grafana**: Linked to Azure Monitor Workspace
- **Managed Istio**: Service mesh with external ingress gateway

## Prerequisites

- Azure CLI with Bicep extension
- Azure subscription with appropriate permissions

## Deploy

```bash
# Deploy with parameters
az deployment sub create \
  --location australiaeast \
  --template-file main.bicep \
  --parameters parameters/env.bicepparam
```

Or deploy without role assignments:

```bash
az deployment sub create \
  --location australiaeast \
  --template-file main.bicep
```

## Validate (without deploying)

```bash
az deployment sub what-if \
  --location australiaeast \
  --template-file main.bicep
```

## Project Structure

```
├── main.bicep                    # Subscription-level entry point
├── bicepconfig.json              # Bicep linting configuration
└── modules/
    ├── resourceGroup.bicep       # Resource group
    ├── aksCluster.bicep          # AKS cluster (Istio, FIPS, Prometheus)
    ├── monitorWorkspace.bicep    # Azure Monitor workspace
    └── grafana.bicep             # Managed Grafana
```
