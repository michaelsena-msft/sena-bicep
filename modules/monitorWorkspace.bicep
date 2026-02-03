param name string
param location string

resource amw 'Microsoft.Monitor/accounts@2023-04-03' = {
  name: name
  location: location
}

output id string = amw.id
output name string = amw.name
