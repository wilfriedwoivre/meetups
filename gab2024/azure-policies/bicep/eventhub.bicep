resource eventhub 'Microsoft.EventHub/namespaces@2017-04-01' = {
  name: 'wwo${deployment().name}${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  sku: {
    name: 'Basic'
    capacity: 1
  }
}
