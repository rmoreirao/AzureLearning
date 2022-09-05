-> https://lab.github.com/githubtraining/github-actions:-continuous-delivery-with-azure
	-> https://github.com/rmoreirao/github-actions-continuous-delivery-azure/pull/3
	https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-github-actions?tabs=userlevel
	https://github.com/Azure/actions-workflow-samples/blob/master/AppService/docker-asp.net-core-webapp-sql-on-azure.yaml

-> Create GitHub Actions -> Aspnet Core to Azure Web App
-> https://docs.microsoft.com/en-us/azure/app-service/deploy-container-github-action?tabs=publish-profile
-> https://lab.github.com/

-> https://timheuer.com/blog/add-approval-workflow-to-github-actions/ 

-> https://foldr.uk/azure-bicep-app-service-custom-container/

-> https://docs.microsoft.com/en-us/azure/devops/pipelines/apps/cd/deploy-docker-webapp?view=azure-devops&tabs=java%2Cyaml

# 01 First App Todo - ASP.NET Core app 6 + Cosmos DB + Azure DevOps (CI) + Bicep

* Naming Convention: {type}-{workload}-{env}-{region}
* Resource Group naming convention: rg-tododockerwebapp-dev-we
* Network: For simplicity, no networking requirements
* Cosmos DB:
	* Account:
		* Account Name: cosmos-firstapp-dev-we
		* Capacity Mode: Provisioned throughput
		* Network:
			* Connect via Public Endpoint for simplicity and select the specific subnet
		* Backup: Locally Redundant
* Web App:
	* Project name: todoDockerWebApp
	* Solution: todo
	* Auth: None
	* HTTP
	
	* App Service:
		* Name: dockerwebapptodoappdev
		* App Service Plan Name: asp-dockerwebapptodoapp-dev-we
		
		* Connection String stored as "App Settings"
* Monitoring:
	* Application Insights
    	* * App Insights Name: appins-webapptodo-dev-we now.. 
* SourceConttrol: GitHub 
* Azure Github as CI / CD
	* Config needed:
		* YAML pipeline configured and on source control - point to azure-pipelines.yml
		* Add Service Connection to be able to deploy to the Web App
		* Create 2 envs: Dev and Prod
		* For Prod add Approver
	* Steps:
		* a. Validate bicep file
		* b. Deploy Infra to Dev
		* c. Deploy Code to Dev
		* d. Do SmokeTest //to be implemented
		* e. Wait approval for Prod
		* f. Deploy Infra to Prod
		* g. Deploy Code to Prod
		* h. Do SmokeTest //to be implemented

# Testing the Web App it locally:
0) Create the Azure infra using commands described inside "infra-as-code.bicep"
1) Copy the cosmos DB primary con string key and set it on appsettings.json
2) run "dotnet run" command inside the "todo" folder

# Build, run and push the Container
## Build and run locally: Access the application via http://localhost:5000 
docker build -t acrtododockerwebappdev4we.azurecr.io/learning/tododockerwebapp:1.0 .
docker run -it --rm -p 5000:80 --name tododockerwebapp_container acrtododockerwebappdev4we.azurecr.io/learning/tododockerwebapp:1.0

## Push container image to ACR (Azure Container Registry)
az login
TOKEN=$(az acr login --name acrtododockerwebappdev4we --expose-token --output tsv --query accessToken)
docker login acrtododockerwebappdev4we.azurecr.io --username 00000000-0000-0000-0000-000000000000 --password $TOKEN

docker push acrtododockerwebappdev4we.azurecr.io/learning/tododockerwebapp:1.0

* What can be enhanced:
	
* Resources:
	* Create Cosmos DB Web App: [ASP.NET Core MVC web app tutorial using Azure Cosmos DB | Microsoft Docs](https://docs.microsoft.com/en-us/azure/cosmos-db/sql/sql-api-dotnet-application)
    * ARM / Bicep Quickstart Template for Web App + CosmosDB + App Insight: [Web App w/ Application Insights sending to Log Analytics (microsoft.com)](https://azure.microsoft.com/en-us/resources/templates/web-app-loganalytics/)
    * 