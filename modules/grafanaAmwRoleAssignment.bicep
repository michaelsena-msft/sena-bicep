param azureMonitorWorkspaceId string
param grafanaPrincipalId string

resource amw 'Microsoft.Monitor/accounts@2023-04-03' existing = {
  name: last(split(azureMonitorWorkspaceId, '/'))
}

resource grafanaMonitoringDataReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(azureMonitorWorkspaceId, grafanaPrincipalId, 'monitoring-data-reader')
  scope: amw
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'b0d8363b-8ddd-447d-831f-62ca05bff136'
    )
    principalId: grafanaPrincipalId
    principalType: 'ServicePrincipal'
  }
}
