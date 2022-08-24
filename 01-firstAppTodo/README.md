# 01 First App Todo - ASP.NET Core app 6 + Cosmos DB 

## Deploy Infra as a Code - Adjust the Variables and names

1) Create Resource Group

az group create --name rg-firstapp-dev3-we --location "westeurope"

2) Import ARM template

az deployment group create --resource-group rg-firstapp-dev3-we  --template-file infra-as-code.bicep --mode Complete --parameters environment=dev3 subnetAddressPrefix=3

<!-- az deployment group create --resource-group rg-firstapp-dev8-we  --template-file test.json -->