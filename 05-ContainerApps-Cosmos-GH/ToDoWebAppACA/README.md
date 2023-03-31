
# Description

This is an Azure Container App sample using ASPNET Core 6 and CosmosDB.
It contains 2 services: a client app and an API app.
To make it easier, I left everything as Development environment and maximun debug.
To run this, first you need to create the ACR, create the images, and then run the IaC. 
# Docker and Docker Compose
#### To build the images using docker compose
docker-compose -f docker-compose.yml -f docker-compose.override.yml build

### To run using Docker compose (dont need to build before)
docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d

### Check processes running
docker ps

### Docker Stop All
docker container stop $(docker container ls -aq)
docker container prune -f


# Upload Image to ACR

API> az acr build --registry acrtodoacawebappwedev1 --image "acrtodoacawebappwedev1/aca-api" --file 'ToDoWebApp.API/Dockerfile' . 
Client> az acr build --registry acrtodoacawebappwedev1 --image "acrtodoacawebappwedev1/aca-client" --file 'ToDoWebApp.Client/Dockerfile' . 

# IaC

Details on how to run it manually on main.bicep file

# Docs

Check other docs here: https://github.com/rmoreirao/AzureContainerAppsFirstApp