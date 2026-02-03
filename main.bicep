targetScope = 'subscription'

param workloadName string
param location string
param ownerObjectId string

var rgName = 'rg-${workloadName}'

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
  params: {}
  dependsOn: [rg]
}

module grafana 'modules/grafana.bicep' = {
  name: 'deploy-grafana'
  scope: resourceGroup(rgName)
  params: {
    azureMonitorWorkspaceId: amw.outputs.id
    ownerObjectId: ownerObjectId
  }
}

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
  params: {}
  dependsOn: [rg]
}

output resourceGroupName string = rg.outputs.name
output grafanaEndpoint string = grafana.outputs.endpoint
output aksPortalUrl string = 'https://portal.azure.com/#resource${aks.outputs.id}'
