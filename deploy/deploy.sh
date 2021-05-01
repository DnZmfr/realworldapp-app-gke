#!/usr/bin/env bash

cd $(dirname "${BASH_SOURCE[0]}")

boldn() {
  echo -n ". $(tput bold)" "$*" "$(tput sgr0)";
}

bold() {
  echo "$(tput bold)" "$*" "$(tput sgr0)";
}

gcloud config set project toptal-realworld-app
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud config set compute/zone us-central1-c
gcloud config set compute/region us-central1

boldn "Create kubernetes cluster..."
CHECK_GKE_CLUSTER=$(gcloud container clusters list| grep cluster-1| wc -l)
if [ ${CHECK_GKE_CLUSTER} -eq 0 ]; then
  gcloud container clusters create cluster-1 --num-nodes=2 --machine-type=e2-medium --enable-autoscaling --max-nodes=3 --min-nodes=2
  gcloud container clusters get-credentials cluster-1 --zone us-central1-c --project toptal-realworld-app
  bold "Done."
else
  bold "Skipping, already exists."
fi

boldn "Create jwt-secret secret..."
CHECK_JWT_SECRET=$(kubectl get secret| grep jwt-secret| wc -l)
if [ ${CHECK_JWT_SECRET} -eq 0 ]; then
  export JWT_SECRET=$(openssl rand -hex 64)
  sed -i "s/JWT_SECRET=.*/JWT_SECRET=$JWT_SECRET/g" backend/Dockerfile
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

boldn "Create mongodb-volume-claim volume claim..."
CHECK_PVC=$(kubectl get pvc| grep mongodb-volume-claim| wc -l)
if [ ${CHECK_PVC} -eq 0 ]; then
  kubectl create -f mongodb-volume.yaml
  bold "Done."
else
  bold "Skipping, already exists."
fi

boldn "Deploy mongodb..."
CHECK_MONGODB_DEPLOY=$(kubectl get deployment| grep mongodb| wc -l)
if [ ${CHECK_MONGODB_DEPLOY} -eq 0 ]; then
  kubectl create -f mongodb-deploy.yaml
  bold "Done."
else
  bold "Skipping, already deployed."
fi

boldn "Deploy backend..."
CHECK_BACKEND_DEPLOY=$(kubectl get deployment| grep realworld-backend| wc -l)
if [ ${CHECK_BACKEND_DEPLOY} -eq 0 ]; then
  kubectl create -f backend-deploy.yaml
  #Frontend needs to know the backend ip address so we wait until an IP is assigned to the backend service.
  while [ $(kubectl get svc realworld-backend -o jsonpath='{.status.loadBalancer.ingress[0].ip}'| wc -c) -eq 0 ]; do sleep 5; done
  export BACKEND_IP=$(kubectl get svc realworld-backend -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  sed -i.orig "s/realworld-backend.default.svc.cluster.local/$BACKEND_IP/g" frontend-deploy.yaml
  bold "Done."
else
  bold "Skipping, already deployed."
fi

boldn "Deploy frontend..."
CHECK_FRONTEND_DEPLOY=$(kubectl get deployment| grep realworld-frontend| wc -l)
if [ ${CHECK_FRONTEND_DEPLOY} -eq 0 ]; then
  kubectl create -f frontend-deploy.yaml
  #Restore the original frontend-deploy.yaml file
  if [ -f frontend-deploy.yaml.orig ]; then
    mv frontend-deploy.yaml.orig frontend-deploy.yaml
  fi
  bold "Done."
else
  bold "Skipping, already deployed."
fi

bold "Done."
