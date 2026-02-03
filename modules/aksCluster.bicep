resource aks 'Microsoft.ContainerService/managedClusters@2024-09-01' = {
  name: '${resourceGroup().name}-aks'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${resourceGroup().name}-aks'
    agentPoolProfiles: [
      {
        name: 'system'
        count: 2
        vmSize: 'Standard_D4s_v3'
        mode: 'System'
        enableFIPS: true
      }
    ]
    azureMonitorProfile: {
      metrics: {
        enabled: true
      }
    }
    serviceMeshProfile: {
      mode: 'Istio'
      istio: {
        components: {
          ingressGateways: [
            {
              enabled: true
              mode: 'External'
            }
          ]
        }
      }
    }
  }
}

output id string = aks.id
