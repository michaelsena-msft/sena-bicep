resource amw 'Microsoft.Monitor/accounts@2023-04-03' = {
  name: '${resourceGroup().name}-amw'
  location: resourceGroup().location
}

output id string = amw.id
