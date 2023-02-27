@description('The random suffix applied to all resources')
param applicationName string = uniqueString(resourceGroup().id)

@description('The location to deploy our resources to')
param location string = resourceGroup().location

@description('The name of our log analytics workspace to deploy')
param lawName string = 'law-${applicationName}'

@description('The name of our App Insights workspace to deploy')
param appInsightsName string = 'appins-${applicationName}'

@description('The name of our container registry')
param acrName string = 'acr${applicationName}'

@description('The name of our Container App environment')
param envName string = 'env-${applicationName}'

@description('The tags to apply to these resource')
param tags object = {
  ApplicationName: 'Bookstore'
  Environment: 'Production'
}

var frontendAppName = 'bookstore-web'

resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: lawName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: law.id
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource env 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: envName
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: law.properties.customerId
        sharedKey: law.listKeys().primarySharedKey
      }
    }
  }
}

resource frontend 'Microsoft.App/containerApps@2022-03-01' = {
  name: frontendAppName
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
          name: frontendAppName
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
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
