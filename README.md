# AKS with Managed Prometheus, Grafana & Istio

Deploys an AKS cluster with FIPS compliance, Istio service mesh, and Azure Monitor integration (Managed Prometheus + Grafana).

## Usage

```bash
# Validate
az deployment sub validate --location australiaeast --template-file main.bicep --parameters parameters/env.bicepparam

# Preview changes
az deployment sub what-if --location australiaeast --template-file main.bicep --parameters parameters/env.bicepparam

# Deploy
az deployment sub create --location australiaeast --template-file main.bicep --parameters parameters/env.bicepparam
```

## Parameters

| Parameter | Description |
|-----------|-------------|
| `workloadName` | Workload name used in resource naming |
| `location` | Azure region for deployment |
| `ownerObjectId` | Entra ID object ID for Grafana admin role |
