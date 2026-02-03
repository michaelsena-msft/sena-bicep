param azureMonitorWorkspaceId string
param ownerObjectId string

resource grafana 'Microsoft.Dashboard/grafana@2023-09-01' = {
  name: '${resourceGroup().name}-grafana'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    grafanaIntegrations: {
      azureMonitorWorkspaceIntegrations: [
        {
          azureMonitorWorkspaceResourceId: azureMonitorWorkspaceId
        }
      ]
    }
  }
}

resource grafanaAdminRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(grafana.id, ownerObjectId, 'grafana-admin')
  scope: grafana
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '22926164-76b3-42b3-bc55-97df8dab3e41'
    )
    principalId: ownerObjectId
    principalType: 'User'
  }
}

output principalId string = grafana.identity.principalId
output endpoint string = grafana.properties.endpoint
