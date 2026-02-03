targetScope = 'subscription'

@description('Workload name used in resource naming (e.g., myproject)')
param workloadName string = 'myproject'

@description('Object ID of the owner/deployer in Entra ID (used for role assignments)')
param ownerObjectId string = ''

var location = 'australiaeast'
var workload = workloadName
var environment = 'env'
var regionCode = 'aue'

var rgName = 'rg-${workload}-${environment}-${regionCode}'
var aksName = 'aks-${workload}-${environment}-${regionCode}'
var amwName = 'amw-${workload}-${environment}-${regionCode}'
var grafanaName = 'grafana-${workload}-${environment}-${regionCode}'

module rg 'modules/resourceGroup.bicep' = {
  name: 'deploy-rg'
  params: {
    name: rgName
    location: location
  }
}

module amw 'modules/monitorWorkspace.bicep' = {
  name: 'deploy-amw'
  scope: resourceGroup(rgName)
  params: {
    name: amwName
    location: location
  }
  dependsOn: [rg]
}

module grafana 'modules/grafana.bicep' = {
  name: 'deploy-grafana'
  scope: resourceGroup(rgName)
  params: {
    name: grafanaName
    location: location
    azureMonitorWorkspaceId: amw.outputs.id
    ownerObjectId: ownerObjectId
  }
}

// Assign Monitoring Data Reader to Grafana's Managed Identity on Azure Monitor Workspace
module grafanaAmwRole 'modules/grafanaAmwRoleAssignment.bicep' = {
  name: 'deploy-grafana-amw-role'
  scope: resourceGroup(rgName)
  params: {
    azureMonitorWorkspaceId: amw.outputs.id
    grafanaPrincipalId: grafana.outputs.principalId
  }
}

module aks 'modules/aksCluster.bicep' = {
  name: 'deploy-aks'
  scope: resourceGroup(rgName)
  params: {
    name: aksName
    location: location
    azureMonitorWorkspaceId: amw.outputs.id
  }
}

output resourceGroupName string = rg.outputs.name
output aksClusterName string = aks.outputs.name
output grafanaName string = grafana.outputs.name
output grafanaEndpoint string = grafana.outputs.endpoint
output aksPortalUrl string = 'https://portal.azure.com/#resource${aks.outputs.id}'
output getCredentialsCommand string = 'az aks get-credentials -g ${rgName} -n ${aksName}'
