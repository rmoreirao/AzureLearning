# 01 First App Todo - ASP.NET Core app 6 + Cosmos DB + Azure DevOps (CI) + Bicep

* Naming Convention: {type}-{workload}-{env}-{region}
* Resource Group naming convention: rg-firstapp-dev-we

* Cosmos DB:
	* Account:
		* Account Name: cosmos-firstapp-dev-we
		* Capacity Mode: Provisioned throughput
		* Network:
			* Connect via Public Endpoint for simplicity and select the specific subnet
			* *** Enable access to Azure Data Centers for simplicity
		* Backup: Locally Redundant
* Web App:
	* Project name: todoWebApp
	* Solution: todo
	* Auth: None
	* HTTP
	
	* App Service:
		* Name: webapptodofirstappdev
		* App Service Plan Name: asp-webapptodofirstapp-dev-we
		* App Insights: appins-webapptodo-dev-we
		* Add Diagnostics Settings to "logan-firstapp-dev-we"
		* *** Not hosted in the Vnet.. Making it simple for now.. 
		* Connection String stored as "App Settings"

* SourceConttrol: GitHub 

* To deploy the application
  * 1) Run the following Script in Powershell to create the Storage Account to store the State file
    * create_storage.ps1
  * 2) Create a Service Principal with Contributor Role to Deploy the Application and set the Secrets in Github
    * Can run the following command for that: az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID" --name="AzLearn04ServicePrincipal"
      * appId (Azure) → client_id 
      * password (Azure) → client_secret 
      * tenant (Azure) → tenant_id
  * 3) Run the CICD pipelines from Github Actions for Terraform and the Web App 


* Resources:
    * Deploy to Azure using Terraform and Github: https://gmusumeci.medium.com/deploying-terraform-in-azure-using-github-actions-step-by-step-bf8804b17711
	* Create Cosmos DB Web App: [ASP.NET Core MVC web app tutorial using Azure Cosmos DB | Microsoft Docs](https://docs.microsoft.com/en-us/azure/cosmos-db/sql/sql-api-dotnet-application)
	* Create CI / CD for the Web App: [Deploy an Azure Web App - Azure Pipelines | Microsoft Docs](https://docs.microsoft.com/en-us/azure/devops/pipelines/targets/webapp?view=azure-devops&tabs=windows%2Cyaml)
	* Bicep CI / CD for Infra as a Code: [CI/CD with Azure Pipelines and Bicep files - Azure Resource Manager | Microsoft Docs](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/add-template-to-azure-pipelines?tabs=CLI)
	* Create CI/CD with Different Environments: https://docs.microsoft.com/en-us/learn/modules/manage-multiple-environments-using-bicep-azure-pipelines/
    * ARM / Bicep Quickstart Template for Web App + CosmosDB + App Insight: [Web App w/ Application Insights sending to Log Analytics (microsoft.com)](https://azure.microsoft.com/en-us/resources/templates/web-app-loganalytics/)