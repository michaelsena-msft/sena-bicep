targetScope = 'subscription'

param workloadName string
param location string

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

module aks 'modules/aksCluster.bicep' = {
  name: 'deploy-aks'
  scope: resourceGroup(rgName)
  params: {}
  dependsOn: [rg]
}

module prometheusCollection 'modules/prometheusCollection.bicep' = {
  name: 'deploy-prometheus-collection'
  scope: resourceGroup(rgName)
  params: {
    aksId: aks.outputs.id
    amwId: amw.outputs.id
  }
}

module adx 'modules/adxCluster.bicep' = {
  name: 'deploy-adx'
  scope: resourceGroup(rgName)
  params: {
    workloadName: workloadName
    location: location
    kubeletIdentityObjectId: aks.outputs.kubeletIdentityObjectId
  }
}

output aksClusterName string = 'aks-${workloadName}'
output adxClusterUri string = adx.outputs.clusterUri
output adxWebExplorerUrl string = 'https://dataexplorer.azure.com/clusters/${adx.outputs.clusterUri}/databases/Metrics'
