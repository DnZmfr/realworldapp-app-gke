# Fullstack RealWorld app

## Overview

This repository contains all the scripts, files and instructions necessary to create the Google Cloud Platform (GCP) infrastructure and perform automated [RealWorld fullstack application](https://github.com/layrjs/react-layr-realworld-example-app) kubernetes deployments with terraform. 

#### Tools & Technologies:
* [GCP](https://cloud.google.com/) - Google Cloud Platform
* [GKE](https://cloud.google.com/kubernetes-engine/) - Google Kubernetes Engine
* [CloudBuild](https://cloud.google.com/build) - Cloud Build Serverless CI/CD Platform
* [Docker](https://www.docker.com/) - Containerization platform
* [Prometheus](https://prometheus.io/) - Time-series metrics monitoring tool
* [Loki](https://grafana.com/oss/loki/) - Multi-tenant log aggregation system
* [Grafana](https://grafana.com/) - Observability dashboards for prometheus metrics

#### Repo Structure

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


### Prepare

## Deploy
