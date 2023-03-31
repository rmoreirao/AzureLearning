# Code based on this course:
https://www.udemy.com/course/deploying-net-microservices-with-k8s-aks-and-azure-devops/
...

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

az acr build --registry $ACR_NAME --image "tasksmanager/$BACKEND_API_NAME" --file 'ToDoWebApp.API/Dockerfile' . 

### 