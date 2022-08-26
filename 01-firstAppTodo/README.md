# 01 First App Todo - ASP.NET Core app 6 + Cosmos DB + Azure DevOps (CI) + Bicep

Naming Convention: {type}-{workload}-{env}-{region}
Resource Group naming convention: rg-firstapp-dev-we
Network:
	Vnet: vnet-firstapp-dev-we - 10.0.0.0/16
	Web App Subnet: snet-firstappwebapp-dev-we - 10.0.1.0/24
	DB Subnet: snet-firstappdb-dev-we - 10.0.2.0/24
Cosmos DB:
	Account:
		Account Name: cosmos-firstapp-dev-we
		Capacity Mode: Provisioned throughput
		Network:
			Connect via Public Endpoint for simplicity and select the specific subnet
			*** Enable access to Azure Data Centers for simplicity
		Backup:
			Locally Redundant
Web App:
	Project name: todoWebApp
	Solution: todo
	Auth: None
	HTTP
	
	App Service:
		Name: webapptodofirstappdev
		App Service Plan Name: asp-webapptodofirstapp-dev-we
		App Insights: appins-webapptodo-dev-we
		Add Diagnostics Settings to "logan-firstapp-dev-we"
		*** Not hosted in the Vnet.. Making it simple for now.. 
		Connection String stored as "App Settings"
Monitoring:
	Application Insights
SourceConttrol: GitHub 
Azure DevOps YAML as CI / CD
	Config needed:
		YAML pipeline configured and on source control - point to azure-pipelines.yml
		Add Service Connection to be able to deploy to the Web App
		Create 2 envs: Dev and Prod
		For Prod add Approver
	Steps:
		a. Validate bicep file
		b. Deploy Infra to Dev
		c. Deploy Code to Dev
		d. Do SmokeTest //to be implemented
		e. Wait approval for Prod
		f. Deploy Infra to Prod
		g. Deploy Code to Prod
		h. Do SmokeTest //to be implemented
		
What can be enhanced:
	• Implement the real Smoke Tests: check here: https://docs.microsoft.com/en-us/learn/modules/manage-multiple-environments-using-bicep-azure-pipelines/
	• Implement a rollback on smoke tests issues: use app service deployment slots for that
	• Enhance security, adding App Service to a Subnet and using Private Link to connect to Cosmos DB
	• Create different Service Connections (one for Dev and other for Prod) on Azure and allow RBAC access to only specific resource groups - Pipeline security
	• Enhance Bicep file
	• Estimate the costs of the solution
	• Create Health Checks and alerts for that - only for prod!!
	• Make App Service Https only
	
Resources:
	Create Cosmos DB Web App: ASP.NET Core MVC web app tutorial using Azure Cosmos DB | Microsoft Docs
	Create CI / CD for the Web App: Deploy an Azure Web App - Azure Pipelines | Microsoft Docs
	Bicep CI / CD for Infra as a Code: CI/CD with Azure Pipelines and Bicep files - Azure Resource Manager | Microsoft Docs
	Create CI/CD with Different Environments: https://docs.microsoft.com/en-us/learn/modules/manage-multiple-environments-using-bicep-azure-pipelines/
ARM / Bicep Quickstart Template for Web App + CosmosDB + App Insight: Web App w/ Application Insights sending to Log Analytics (microsoft.com)