param name string
param location string
param azureMonitorWorkspaceId string
param grafanaAdminObjectId string = ''

resource grafana 'Microsoft.Dashboard/grafana@2023-09-01' = {
  name: name
  location: location
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

// Grafana Admin role assignment for user
resource grafanaAdminRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(grafanaAdminObjectId)) {
  name: guid(grafana.id, grafanaAdminObjectId, 'grafana-admin')
  scope: grafana
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '22926164-76b3-42b3-bc55-97df8dab3e41'
    )
    principalId: grafanaAdminObjectId
    principalType: 'User'
  }
}

output id string = grafana.id
output name string = grafana.name
output principalId string = grafana.identity.principalId
output endpoint string = grafana.properties.endpoint
