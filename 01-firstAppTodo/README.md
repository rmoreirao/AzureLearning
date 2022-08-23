# 01 First App Todo - ASP.NET Core app + Cosmos DB 


# Deploy Infra as a Code

az group create --name rg-firstapp-dev8-we --location "westeurope"
az deployment group create --resource-group rg-firstapp-dev8-we  --template-file infra-as-code.json --mode Complete --parameters environment=dev8 subnetAddressPrefix=8


<!-- az deployment group create --resource-group rg-firstapp-dev8-we  --template-file test.json -->