# Copilot Instructions

Azure Bicep infrastructure-as-code for deploying a production-ready AKS cluster with Managed Prometheus, Grafana, and Istio service mesh.

## Commands

```bash
# Validate deployment (what-if)
az deployment sub what-if --location australiaeast --template-file main.bicep

# Deploy
az deployment sub create --location australiaeast --template-file main.bicep --parameters parameters/env.bicepparam

# Lint Bicep files
az bicep lint --file main.bicep
az bicep lint --file modules/aksCluster.bicep  # Lint a single module
```

## Architecture

- **Entry point**: `main.bicep` is a subscription-level deployment that orchestrates all modules
- **Modules pattern**: Each Azure resource type has its own module in `modules/` with explicit params and outputs
- **Parameters**: Environment-specific values go in `parameters/*.bicepparam` files using the `using` syntax

### Module Dependencies

```
main.bicep (subscription scope)
├── resourceGroup.bicep
├── monitorWorkspace.bicep
├── grafana.bicep
│   └── grafanaAmwRoleAssignment.bicep (links Grafana identity to AMW)
└── aksCluster.bicep (includes DCR/DCRA for Prometheus)
```

## Conventions

### Naming

Resources follow the pattern: `{type}-{workload}-{environment}-{regionCode}` (e.g., `aks-sena-env-aue`)

### Module Design

- Modules accept explicit parameters rather than constructing names internally
- Each module outputs `id` and `name` at minimum
- Role assignments use `guid()` with resource ID + principal ID + role name for deterministic assignment names
- Use `subscriptionResourceId()` for built-in role definition IDs

### Bicep Style

- Use `@description()` decorators on parameters that need clarification
- Conditional resources use `if (!empty(param))` pattern for optional features
- `dependsOn` is explicit when implicit dependencies aren't sufficient
