

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
		* Create Service Principal on Azure, assign role to it and create a password
		* Create 2 envs: development and production
    		* For production: it should also have approver
	* Steps:
		* a. Deploy Infra to Dev
		* b. Deploy Code to Dev
		* c. Wait approval for Prod
		* d. Deploy Infra to Prod
		* e. Deploy Code to Prod
    * YAML pipeline configured and on Github: 
    		* 02-ci-cd-workflow.yml: Full CI/CD Flow - for Dev and Prod
    		* 02-github-ci-cd-workflow-generic.yml: Generic steps for deploying to one env
# Testing the Web App it locally:
0) Create the Azure infra using commands described inside "infra-as-code.bicep"
1) Copy the cosmos DB primary con string key and set it on appsettings.json
2) run "dotnet run" command inside the "todo" folder

# Build, run and push the Container
## Build and run locally: Access the application via http://localhost:5000 
docker build -t acrtododockerwebappdev5we.azurecr.io/learning/tododockerwebapp:1.0 .
docker run -it --rm -p 5000:80 --name tododockerwebapp_container acrtododockerwebappdev5we.azurecr.io/learning/tododockerwebapp:1.0

## Push container image to ACR (Azure Container Registry)
az login
TOKEN=$(az acr login --name acrtododockerwebappdev5we --expose-token --output tsv --query accessToken)
docker login acrtododockerwebappdev5we.azurecr.io --username 00000000-0000-0000-0000-000000000000 --password $TOKEN

docker push acrtododockerwebappdev5we.azurecr.io/learning/tododockerwebapp:1.0

* What can be enhanced:
  * Currently we create on Azure Registry Container for each env, this should be shared
  * Separate the Build and Release flows: first build images and send to ACR, then deploy to the different environments
  * Add automated tests and Code / Security checks
	
* Resources:
	* Create Cosmos DB Web App: [ASP.NET Core MVC web app tutorial using Azure Cosmos DB | Microsoft Docs](https://docs.microsoft.com/en-us/azure/cosmos-db/sql/sql-api-dotnet-application)
    * ARM / Bicep Quickstart Template for Web App + CosmosDB + App Insight: [Web App w/ Application Insights sending to Log Analytics (microsoft.com)](https://azure.microsoft.com/en-us/resources/templates/web-app-loganalytics/)
    * Nice Github Info for CI: https://lab.github.com/githubtraining/github-actions:-continuous-delivery-with-azure
	* Deploy ARM using Github actions: https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-github-actions?tabs=userlevel
	* Docker ASP.NET Core app with SQL: https://github.com/Azure/actions-workflow-samples/blob/master/AppService/docker-asp.net-core-webapp-sql-on-azure.yaml
	* Deploy Containers to Github: https://docs.microsoft.com/en-us/azure/app-service/deploy-container-github-action?tabs=publish-profile
	* Github Labs: https://lab.github.com/
	* Adding Approval WF to Github: https://timheuer.com/blog/add-approval-workflow-to-github-actions/ 