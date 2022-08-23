# AzureLearning

This is a Repo which contains my hands on learning path to Azure

# Deploy Infra as a Code

az group create --name rg-firstapp-dev7-we --location "westeurope"
az deployment group create --resource-group rg-firstapp-dev7-we  --template-file infra-as-code.json --mode Complete --parameters environment=dev7 subnetAddressPrefix=7


az deployment group create --resource-group rg-firstapp-dev7-we  --template-file test.json