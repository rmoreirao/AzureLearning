# Description of the App
- ASPNET Core 6
  - Front End: ASPNET Core MVC Web App
  - Back End: ASPNET Core API
- DB: CosmosDB
- CI/CD: Github
- Containers: Docker + AKS + Helm

# Resources
Helpful information can be found on "AzureLearningAKS" repo!

# Steps to develop the App
1) Create the CosmosDB DB - created it using the bicep file in the iac folder
2) Create the API and test it - created using Visual Studio
3) Create the Front End - created using Visual Studio
4) Create Docker files from both Back End and Front End - created it using Visual Studio
5) Configure Docker Compose using Visual Studio and test also using it
6) Migrate to AKS
   1) Created manifest files using VS Code
   2) ASK using the Bicep
   3) Test using VS Code
7) Configure CI CD workflow using GH

# Running the App
## CI / CD using GH
### Setup CI CD User Rights
CI CD User in Azure needs Contributor and User Access Administrator roles
### Set the following Github Secrets:
- 03_AKS_ACR_NAME: name of ACR
- 03_AKS_ACR_URL: URL for the ACR
- 03_AKS_CLIENT_ID: Client ID user connecting from Github to Azure
- 03_AKS_CLIENT_SECRET: Secret to connect from Github to Azure
- 03_AKS_LOCATION: Azure Location - ex.: westeurope
- 03_AKS_LOCATION_SUFFIX: Azure Location Suffix - ex.: we
- 03_AKS_SUBSCRIPTION_ID: Azure Subscription ID
- 03_AKS_TENANT_ID: Azure Tenant ID
