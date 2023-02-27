@description('The random suffix applied to all resources')
param applicationName string = uniqueString(resourceGroup().id)

@description('The location to deploy this Container App')
param location string = resourceGroup().location

@description('The tags to apply to this container app')
param tags object = {
  ApplicationName: 'Bookstore'
  Environment: 'Production'
  Component: 'API'
}

@description('The name of the environment that this Container App will use')
param envName string = 'env-${applicationName}'

@description('The name of the container registry that this Container App will use')
param acrName string = 'acr${applicationName}'

@description('The name of the Container Image that this container app will use')
param containerImage string

var backendAppName = 'bookstore-api'

resource env 'Microsoft.App/managedEnvironments@2022-10-01' existing = {
  name: envName
}

resource acr 'Microsoft.ContainerRegistry/registries@2022-12-01' existing = {
  name: acrName
}

resource backend 'Microsoft.App/containerApps@2022-03-01' = {
  name: backendAppName
  location: location
  tags: tags
  properties: {
    managedEnvironmentId: env.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
        allowInsecure: false
      }
      activeRevisionsMode: 'Multiple'
      secrets: [
        {
          name: 'containerregistry-password'
          value: acr.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: acr.properties.loginServer
          passwordSecretRef: 'containerregistry-password'
          username: acr.listCredentials().username
        }
      ]
    }
    template: {
      containers: [
        {
          name: backendAppName
          image: containerImage
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 3
        rules: [
          {
            name: 'http-scale-rule'
            http: {
              metadata: {
                concurrentRequests: '100'
              }
            }
          }
        ]
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}
