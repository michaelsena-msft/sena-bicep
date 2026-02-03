# AKS with Managed Prometheus, Grafana & Istio

Bicep deployment for a production-ready AKS cluster in Australia East with FIPS compliance, Managed Prometheus, Grafana, and Istio service mesh.

## Resources

| Resource | Name Pattern |
|----------|--------------|
| Resource Group | `rg-{workload}-env-aue` |
| AKS Cluster | `aks-{workload}-env-aue` |
| Azure Monitor Workspace | `amw-{workload}-env-aue` |
| Managed Grafana | `grafana-{workload}-env-aue` |

## Usage

```bash
# Validate
az deployment sub validate --location australiaeast --template-file main.bicep --parameters parameters/env.bicepparam

# Preview changes
az deployment sub what-if --location australiaeast --template-file main.bicep --parameters parameters/env.bicepparam

# Deploy (outputs shown after completion)
az deployment sub create --location australiaeast --template-file main.bicep --parameters parameters/env.bicepparam --query properties.outputs

# View outputs from previous deployment
az deployment sub show --name main --query properties.outputs
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `workloadName` | `myproject` | Workload name used in resource naming |
| `ownerObjectId` | `''` | Entra ID object ID for Grafana admin role |

## Structure

```
├── main.bicep              # Subscription-level entry point
├── bicepconfig.json        # Linting config
├── parameters/             # Environment-specific params
└── modules/
    ├── resourceGroup.bicep
    ├── aksCluster.bicep
    ├── monitorWorkspace.bicep
    ├── grafana.bicep
    └── grafanaAmwRoleAssignment.bicep
```
