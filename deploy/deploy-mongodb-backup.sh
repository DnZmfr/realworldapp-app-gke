#!/usr/bin/env bash
# creates the mongodb-backup cronjob

cd $(dirname "${BASH_SOURCE[0]}")

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

bold "Build new mongodb-backup docker image"
docker build -t gcr.io/${GOOGLE_CLOUD_PROJECT}/mongodb-backup:latest ../mongodb-backup/
bold "Push the new image to Google Container Registry"
docker push gcr.io/${GOOGLE_CLOUD_PROJECT}/mongodb-backup:latest

bold "Create gcp-key secret"
kubectl create secret generic gcp-key --from-file=service-account.json=/home/zamfidan/.google/realworld-tf-gke.json
bold "Deploy k8s cronjob"
kubectl create -f mongodb-cronjob.yaml
