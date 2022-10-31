# API Helm Deploy

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
            ./aks-helm/todowebappapi \
            --debug 


### To delete the resources
helm upgrade todowebappapi