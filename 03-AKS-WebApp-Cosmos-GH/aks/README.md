# Setup Kubernets on your local env and basic commands
### install AKS cli:
az aks install-cli

### Configure AKS in your local kubernets
az aks get-credentials --resource-group rg-todoakswebapp-dev1-we --name aks-todoakswebapp-dev1-we

### From now on, all commends will be executed on AKS
kubectl get all

### Load all yaml into AKS
### From previous folder
kubectl apply -f .\aks\

### check external IP and access to use the App
kubectl get service


# API Deploy

### Nice resources
https://learn.microsoft.com/en-us/training/modules/aks-deployment-pipeline-github-actions/8-helm

### Parameters are defined in values.yaml

### Check the content of the Manifest of after the transformation
helm template todowebappapi

### Applying Helm template - execute from root folder
helm upgrade \
            --install \
            --atomic \
            --wait \
            todowebappapi \
            ./todowebappapi \
            --debug 

### Check the status of the pods
kubectl get pods
kubectl describe pod pod_id_here

### To delete the resources
helm upgrade todowebappapi

# To run Kubernetes locally
### Build the images using docker compose
docker-compose -f ../ToDoWebAppAKS/docker-compose.yml -f ../ToDoWebAppAKS/docker-compose.override.yml build

## Run kubernetes using Helm
### Update the connstring on file todowebappapi/values-localdev
### Applying Helm template for API - execute from root folder
helm upgrade \
            --install \
            --atomic \
            --wait \
            -f ./todowebappapi/values-localdev.yaml \
            todowebappapi \
            ./todowebappapi \
            --debug 

### Applying Helm template for Client - execute from root folder
helm upgrade \
            --install \
            --atomic \
            --wait \
            -f ./todowebappclient/values-localdev.yaml \
            todowebappclient \
            ./todowebappclient \
            --debug 

### Check the status of the pods - to investigate issues if they are not live
kubectl get pods
kubectl describe pod

### Check the running Services
kubectl get services