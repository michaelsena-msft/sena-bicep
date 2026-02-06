param workloadName string
param location string
param kubeletIdentityObjectId string

resource adx 'Microsoft.Kusto/clusters@2024-04-13' = {
  name: 'adx${workloadName}'
  location: location
  sku: {
    name: 'Standard_E2ads_v5'
    tier: 'Standard'
    capacity: 2
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enableStreamingIngest: true
    optimizedAutoscale: {
      isEnabled: true
      version: 1
      minimum: 2
      maximum: 4
    }
  }
}

resource metricsDb 'Microsoft.Kusto/clusters/databases@2024-04-13' = {
  name: 'Metrics'
  parent: adx
  location: location
  kind: 'ReadWrite'
  properties: {
    hotCachePeriod: 'P31D'
    softDeletePeriod: 'P365D'
  }
}

resource logsDb 'Microsoft.Kusto/clusters/databases@2024-04-13' = {
  name: 'Logs'
  parent: adx
  location: location
  kind: 'ReadWrite'
  properties: {
    hotCachePeriod: 'P31D'
    softDeletePeriod: 'P365D'
  }
}

resource metricsPrincipal 'Microsoft.Kusto/clusters/databases/principalAssignments@2024-04-13' = {
  name: 'metrics-kubelet-admin'
  parent: metricsDb
  properties: {
    principalId: kubeletIdentityObjectId
    role: 'Admin'
    principalType: 'App'
    tenantId: subscription().tenantId
  }
}

resource logsPrincipal 'Microsoft.Kusto/clusters/databases/principalAssignments@2024-04-13' = {
  name: 'logs-kubelet-admin'
  parent: logsDb
  properties: {
    principalId: kubeletIdentityObjectId
    role: 'Admin'
    principalType: 'App'
    tenantId: subscription().tenantId
  }
}

output clusterUri string = adx.properties.uri
output clusterName string = adx.name
