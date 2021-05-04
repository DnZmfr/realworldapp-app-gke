#!/usr/bin/env bash

cd $(dirname "${BASH_SOURCE[0]}")

boldn() {
  echo -n ". $(tput bold)" "$*" "$(tput sgr0)";
}

bold() {
  echo "$(tput bold)" "$*" "$(tput sgr0)";
}

export PROJECT_ID="toptal-realworld-app"
export COMPUTE_ZONE="us-central1-c"
export COMPUTE_REGION="us-central1"
export CLUSTER_NAME="realworld-cluster"

gcloud config set project ${PROJECT_ID}
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud config set compute/zone ${COMPUTE_ZONE}
gcloud config set compute/region ${COMPUTE_REGION}

boldn "Create kubernetes cluster..."
CHECK_GKE_CLUSTER=$(gcloud container clusters list| grep ${CLUSTER_NAME}| wc -l)
if [ ${CHECK_GKE_CLUSTER} -eq 0 ]; then
  gcloud container clusters create ${CLUSTER_NAME} --num-nodes=2 --machine-type=e2-medium --enable-autoscaling --max-nodes=3 --min-nodes=2
  gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${COMPUTE_ZONE} --project ${PROJECT_ID}
  bold "Done."
else
  bold "Skipping, already exists."
fi

boldn "Create jwt-secret secret..."
CHECK_JWT_SECRET=$(kubectl get secret| grep jwt-secret| wc -l)
if [ ${CHECK_JWT_SECRET} -eq 0 ]; then
  export JWT_SECRET=$(openssl rand -hex 64)
  kubectl create secret generic jwt-secret --from-literal=JWT_SECRET=${JWT_SECRET}
  bold "Done."
else
  bold "Skipping, already exists."
fi

boldn "Create mongodb-passwd secret..."
CHECK_MONGODB_PASSWD=$(kubectl get secret| grep mongodb-passwd| wc -l)
if [ ${CHECK_MONGODB_PASSWD} -eq 0 ]; then
  kubectl create secret generic mongodb-passwd --from-literal=DB_PASSWORD=test
  bold "Done."
else
  bold "Skipping, already exists."
fi

boldn "Create mongodb-configmap configmap..."
CHECK_MONGODB_CFGMAP=$(kubectl get configmap| grep mongodb-configmap| wc -l)
if [ ${CHECK_MONGODB_CFGMAP} -eq 0 ]; then
  kubectl create configmap mongodb-configmap --from-file mongo-init.js
  bold "Done."
else
  bold "Skipping, already exists."
fi

boldn "Create mongodb-pvc volume claim..."
CHECK_PVC=$(kubectl get pvc| grep mongodb-pvc| wc -l)
if [ ${CHECK_PVC} -eq 0 ]; then
  kubectl create -f pvc-mongodb.yaml
  bold "Done."
else
  bold "Skipping, already exists."
fi

boldn "Deploy mongodb..."
CHECK_MONGODB_DEPLOY=$(kubectl get deployment| grep mongodb| wc -l)
if [ ${CHECK_MONGODB_DEPLOY} -eq 0 ]; then
  kubectl create -f deploy-mongodb.yaml
  bold "Done."
else
  bold "Skipping, already deployed."
fi

boldn "Deploy backend..."
CHECK_BACKEND_DEPLOY=$(kubectl get deployment| grep realworld-backend| wc -l)
if [ ${CHECK_BACKEND_DEPLOY} -eq 0 ]; then
  kubectl create -f deploy-backend.yaml
  #Frontend needs to know the backend ip address so we wait until an IP is assigned to the backend service.
  while [ $(kubectl get svc realworld-backend -o jsonpath='{.status.loadBalancer.ingress[0].ip}'| wc -c) -eq 0 ]; do sleep 5; done
  export BACKEND_IP=$(kubectl get svc realworld-backend -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  sed -i.orig "s/realworld-backend.default.svc.cluster.local/$BACKEND_IP/g" deploy-frontend.yaml
  bold "Done."
else
  bold "Skipping, already deployed."
fi

boldn "Deploy frontend..."
CHECK_FRONTEND_DEPLOY=$(kubectl get deployment| grep realworld-frontend| wc -l)
if [ ${CHECK_FRONTEND_DEPLOY} -eq 0 ]; then
  kubectl create -f deploy-frontend.yaml
  #Restore the original deploy-frontend.yaml file
  if [ -f deploy-frontend.yaml.orig ]; then
    mv deploy-frontend.yaml.orig deploy-frontend.yaml
  fi
  bold "Done."
else
  bold "Skipping, already deployed."
fi

bold "Done."
