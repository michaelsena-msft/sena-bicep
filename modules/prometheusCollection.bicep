param aksId string
param amwId string

var aksName = last(split(aksId, '/'))

resource dcr 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: '${resourceGroup().name}-dcr'
  location: resourceGroup().location
  kind: 'Linux'
  properties: {
    dataSources: {
      prometheusForwarder: [
        {
          name: 'PrometheusDataSource'
          streams: ['Microsoft-PrometheusMetrics']
        }
      ]
    }
    destinations: {
      monitoringAccounts: [
        {
          accountResourceId: amwId
          name: 'MonitoringAccount'
        }
      ]
    }
    dataFlows: [
      {
        destinations: ['MonitoringAccount']
        streams: ['Microsoft-PrometheusMetrics']
      }
    ]
  }
}

resource dcra 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = {
  name: '${resourceGroup().name}-dcra'
  scope: aks
  properties: {
    dataCollectionRuleId: dcr.id
  }
}

resource aks 'Microsoft.ContainerService/managedClusters@2024-09-01' existing = {
  name: aksName
}
