# Deployment Notes & Learnings

Captured during the initial deployment on 2026-02-06.

## Design Decisions

### Two-layer monitoring (not one)

ADX-Mon is **application-focused only** — it scrapes pods annotated with `adx-mon/scrape: "true"`. It does NOT collect cluster health metrics (node-exporter, kube-state-metrics, kubelet) out of the box.

Internal AKS teams run **both** Prometheus and ADX-Mon in parallel. No internal team relies on ADX-Mon alone for cluster health. Therefore:

- **Layer 1 (cluster health):** Azure Monitor Workspace + Prometheus Data Collection Rule. Built-in, zero config, collects node/pod/kubelet metrics automatically.
- **Layer 2 (app observability):** ADX-Mon → ADX cluster. Collects application metrics and logs from annotated pods.

ADX-Mon *can* scrape infrastructure metrics via `[[prometheus-scrape.static-scrape-target]]` in its TOML config, but this requires manually installing kube-state-metrics and node-exporter Helm charts plus configuring static scrape targets. Not worth the complexity when Managed Prometheus handles it natively.

### Grafana removed

Azure Managed Grafana was removed. ADX Web Explorer provides a clickable query UI for metrics and logs stored in ADX. Grafana can be added back later with an ADX data source if dashboarding is needed.

The `adxWebExplorerUrl` output replaces the old Grafana endpoint as the clickable link.

### ADX cluster identity

ADX-Mon writes to ADX using the **kubelet managed identity** (not the AKS cluster identity). This is the identity that pods use, accessed via `aks.properties.identityProfile.kubeletidentity.objectId`. The principal type is `App` (not `User`), and it needs `Admin` role on both Metrics and Logs databases.

### ADX naming

ADX cluster names must be 4-22 characters, alphanumeric and hyphens only, starting with a letter. We use `adx${workloadName}` (no hyphen) to stay safe. The AKS cluster uses `${resourceGroup().name}-aks` which produces `rg-sena-aks`.

## Deployment Timing

| Resource | Time |
|---|---|
| Resource Group | ~6s |
| Azure Monitor Workspace | ~20s |
| AKS cluster | ~8 min |
| Prometheus Data Collection Rule | ~10s (after AKS) |
| ADX cluster + databases + principals | ~12 min (after AKS) |
| **Total** | **~20 min** |

RG deploys first, then AKS + AMW in parallel, then Prometheus DCR + ADX after AKS completes (both need AKS outputs).

## Debugging Tips

### Use validate and what-if before deploying

Full deployments take ~20 min. Use these for faster feedback:

```bash
# Validate (~10s) — checks syntax, schema, and parameter values
az deployment sub validate \
  --location australiaeast \
  --template-file main.bicep \
  --parameters main.bicepparam

# What-if (~30s) — dry-run against Azure, shows what would be created/changed/deleted
az deployment sub what-if \
  --location australiaeast \
  --template-file main.bicep \
  --parameters main.bicepparam
```

### Bicep compilation

If `az bicep build` or `az deployment` hangs, the Bicep CLI can be invoked directly:

```bash
~/.azure/bin/bicep build main.bicep
```

This bypasses the `az` shim entirely. Useful when `az bicep` has issues with Python venv symlinks (e.g. after a mise Python version change).

### Monitor a running deployment

Don't wait blindly. Check sub-operation status:

```bash
# Overall status
az deployment sub show --name sena --query properties.provisioningState -o tsv

# Per-module status
az deployment operation sub list --name sena \
  --query '[].{resource:properties.targetResource.resourceName, state:properties.provisioningState, duration:properties.duration}' \
  -o table
```

### Active deployment conflict

If you get `DeploymentActive` error, a previous deployment with the same name is still running. Either wait for it or cancel:

```bash
az deployment sub cancel --name sena
```

### ADX Web Explorer URL

The `adx.properties.uri` returns `https://host.kusto.windows.net`. The Web Explorer URL format is:

```
https://dataexplorer.azure.com/clusters/{host}/databases/{db}
```

The host must NOT include `https://` — use Bicep's `replace()` to strip it:

```bicep
replace(adx.outputs.clusterUri, 'https://', '')
```

## ADX-Mon Details

### What gets installed

The bundle script installs into two namespaces:

- `adx-mon`: collector (DaemonSet, one per node), collector-singleton, ingestor (StatefulSet)
- `monitoring`: kube-state-metrics (2 shards)

### Pod annotations for scraping

Add these to any pod template to have ADX-Mon collect its metrics/logs:

```yaml
annotations:
  adx-mon/scrape: "true"                        # enable metric scraping
  adx-mon/log-destination: "Logs:<table-name>"   # ship container logs to ADX
```

### ADX-Mon docs

- Repo: https://github.com/Azure/adx-mon
- Config reference: https://github.com/Azure/adx-mon/blob/main/docs/config.md
