# Fullstack RealWorld app

## Overview

This repository contains the app source code and all the scripts, files and instructions necessary to create the Google Cloud Platform (GCP) infrastructure and perform automated [RealWorld fullstack application](https://github.com/layrjs/react-layr-realworld-example-app) kubernetes deployments with terraform. 

#### Tools & Technologies:
* [GCP](https://cloud.google.com/) - Google Cloud Platform
* [GKE](https://cloud.google.com/kubernetes-engine/) - Google Kubernetes Engine
* [CloudBuild](https://cloud.google.com/build) - Cloud Build Serverless CI/CD Platform
* [Docker](https://www.docker.com/) - Containerization platform
* [Prometheus](https://prometheus.io/) - Time-series metrics monitoring tool
* [Loki](https://grafana.com/oss/loki/) - Multi-tenant log aggregation system
* [Grafana](https://grafana.com/) - Observability dashboards for prometheus metrics

#### Repository Structure

```
.
├── LICENSE                                  # LICENSE file
├── README.md                                # README file
├── frontend                                 # directory containing Dockerfile and Frontend app source code 
│   ├── Dockerfile                           # dockerfile for the Frontend container
│   └── src/*                                # frontend app source code (React and Layr)
├── backend                                  # directory containing Dockerfile and Backend app source code 
│   ├── Dockerfile                           # dockerfile for the Backend container
│   └── src/*                                # backend app source code (React and Layr)
├── mongodb-backup                           # directory containing MongoDB backup solution
│   ├── Dockerfile                           # dockerfile for the MongoDB backup container
│   └── backup.sh                            # mongoDB backup script
└── deploy                                   # directory containing code for deployment of infrastructure and fullstack app
    ├── prepare.sh                           # bash script to prepare GCP for automated deployments
    ├── deploy-mongodb-backup.sh             # bash script to deploy the MongoDB backup k8s cronjob
    ├── mongodb-cronjob.yaml                 # k8s cronjob manifest for the MongoDB backup
    ├── cloudbuild                           # directory containing CloudBuild jobs/pipelines
    │   ├── build-app-auto.yaml              # cloudBuild pipeline for automated container builders - triggered by new repo commits
    │   ├── deploy-gke-manual.yaml           # cloudBuild pipeline for manual Kubernetes cluster depooyment
    │   ├── deploy-app-manual.yaml           # cloudBuild pipeline for manual fullstack app deployments
    │   ├── deploy-app-auto.yaml             # cloudBuild pipeline for automated fullstack app deployments - triggered by new GCR images 
    │   └── deploy-monitoring-manual.yaml    # cloudBuild pipeline for manual monitoring stack deployments - Loki, Grafana, 
    └── terraform                            # directory containing Terraform deployment code 
        ├── global_vars.tf                   # terraform variable definitions file
        ├── global_vars.auto.tfvars          # terraform variable values file
        ├── gke                              # directory containing terraform GKE deployment module with google provider
        │   ├── main.tf                      # main GKE deployment/creation
        │   ├── variables.tf                 # symbolic link to ../global_vars.tf to avoid duplicated variable definitions
        │   ├── variables.auto.tfvars        # symbolic link to ../global_vars.auto.tfvars to avoid duplicated variables
        │   └── output.tf                    # terraform output file
        ├── app                              # directory containing terraform APP deployment module with kubernetes provider
        │   ├── main.tf                      # main fullstack app deployment - MongoDB, Backend, Frontend
        │   ├── variables.tf                 # symbolic link to ../global_vars.tf to avoid duplicated variable definitions
        │   ├── variables.auto.tfvars        # symbolic link to ../global_vars.auto.tfvars to avoid duplicated variables
        │   └── output.tf                    # terraform output file
        └── monitoring                       # directory containing terraform monitoring stack deployment module with kubernetes and helm providers
            ├── main.tf                      # main monitoring stack deployment - Prometheus, Loki, Grafana
            ├── variables.tf                 # symbolic link to ../global_vars.tf to avoid duplicated variable definitions
            ├── variables.auto.tfvars        # symbolic link to ../global_vars.auto.tfvars to avoid duplicated variables
            └── templates                    # directory containing helm template value files for Prometheus and Grafana
                ├── prometheus-values.yaml   # prometheus template values file
                └── grafana-values.yaml      # grafana template values file         
```
#### Architecture diagram


## Prerequisites

* A GCP account
* A Github account


## Prepare

Authenticate to the GCP account and create a project with id "toptal-realworld-app".  
On a google Cloud Shell terminal, clone this git repository:
```
git clone https://github.com/DnZmfr/realworldapp-app-gke.git
```
Then run [deploy/prepare.sh](deploy/prepare.sh) script to enable some APIs, create a service account and grant required roles in order to perform automated deployments via cloud build
```
cd realworldapp-app-gke/deploy
./prepare.sh
```
#### Cloud Build Triggers
All Cloud Build triggers needs to be manualy created as the api it's still in alpha/beta and so it is not fully functional.

* Connect GitHup repository.
* Create Triggers with the following configurations:

1. __Build-APP-Auto__  
Event: Push to a branch  
Included files filter (glob): "frontend/\*\*" "backend/\*\*"  
Cloud Build configuration file location: deploy/cloudbuild/build-app-auto.yaml

1. __Deploy-APP-Auto__  
Event: Pub/Sub message  
Subscription: projects/toptal-realworld-app/topics/gcr  
Cloud Build configuration file location: deploy/cloudbuild/deploy-app-auto.yaml  
Substitution variables:  
_ACTION: $(body.message.data.action)  
_IMAGE_TAG: $(body.message.data.tag)  
Filters: _IMAGE_TAG.matches("frontend") && _ACTION == "INSERT"

1. __Deploy-APP-Manual__  
Event: Manual invocation  
Cloud Build configuration file location: deploy/cloudbuild/deploy-app-manual.yaml  
Substitution variables:  
_IMAGE_TAG: 3c9d717

1. __Deploy-GKE-Manual__  
Event: Manual invocation  
Cloud Build configuration file location: deploy/cloudbuild/deploy-gke-manual.yaml

1. __Deploy-MON-Manual__  
Event: Manual invocation  
Cloud Build configuration file location: deploy/cloudbuild/deploy-monitoring-manual.yaml


## Deploy

#### GKE cluster deployment
On _**Cloud Build**_ -> _**Triggers**_, click on _**RUN**_ button of _**Deploy-GKE-Manual**_ trigger and then hit _**RUN TRIGGER**_ button.

#### APP stack deployment (MongoDB, Backend, Frontend)
Any update in the source code of frontend or backend services  will trigger an automated build followed by an automated deployment. 

As soon as the new update is it pushed to git, the _**Build-APP-Auto**_ trigger will start to build new docker container images for frontend and backend services and push them to GCR.  
Once the new container images are pushed to GCR, the _**Deploy-APP-Auto**_ trigger will start a terraform deployment of the full stack to the Kubernetes cluster. 

The terraform deployment state will be saved to a GCS (Google Cloud Storage) bucket so future deployments would also be possible to be performed via Cloud Shell terminal or other deployment machines where Cloud SDK Command Line tools is configured.

#### MongoDB backup cronjob deployment
From a google Cloud Shell terminal, run the following script:
```
cd realworldapp-app-gke/deploy
./deploy-mongodb-backup.sh
```

Note: to change the cronjob schedule, line number 6 in the [deploy/mongodb-cronjob.yaml](deploy/mongodb-cronjob.yaml) file must be updated:
```
  schedule: "0 12 * * *"
```

#### Monitoring deployment (Prometheus, Loki, Grafana)
On _**Cloud Build**_ -> _**Triggers**_, click on _**RUN**_ button of _**Deploy-MON-Manual**_ trigger and then hit _**RUN TRIGGER**_ button.


## Teardown
From google Cloud Shell terminal

#### Delete Monitoring
```
cd realworldapp-app-gke/deploy/terraform/monitoring
terraform init
terraform destroy -auto-approve
```

#### Delete APP Stack
```
cd realworldapp-app-gke/deploy/terraform/app
terraform init
terraform destroy -auto-approve
```

#### Delete GKE cluster
```
cd realworldapp-app-gke/deploy/terraform/gke
terraform init
terraform destroy -auto-approve
```
