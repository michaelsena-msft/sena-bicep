targetScope = 'subscription'

param name string
param location string

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: name
  location: location
}

output name string = rg.name
output id string = rg.id
