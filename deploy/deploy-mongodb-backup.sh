#!/usr/bin/env bash

cd $(dirname "${BASH_SOURCE[0]}")

function bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

function show_usage() {
  echo -e "This script builds a mongodb-backup docker image and deploys the k8s cronjon.\n
  ERROR: command name argument is expected.\n
  Available commands:
  build     builds and deploy a new container image
  deploy    deploy only"
  echo -e "\nUsage: $0 <build|deploy>\n"
}

function build {
  bold "Build new mongodb-backup docker image"
  docker build -t gcr.io/${GOOGLE_CLOUD_PROJECT}/mongodb-backup:latest ../mongodb-backup/

  bold "Push the new image to Google Container Registry"
  docker push gcr.io/${GOOGLE_CLOUD_PROJECT}/mongodb-backup:latest
}

function deploy {
  bold "Generate kubeconfig"
  rm -f ${HOME}/.kube/config
  gcloud container clusters get-credentials realworld-cluster --zone us-central1-c --project ${GOOGLE_CLOUD_PROJECT}

  bold "Create gcp-key secret"
  kubectl create secret generic gcp-key --from-file=service-account.json=${HOME}/.google/realworld-tf-gke.json

  bold "Deploy k8s cronjob"
  kubectl apply -f mongodb-cronjob.yaml
}

function process_args() {
  while [[ $# > 0 ]]; do
    local arg="$1"
    shift
    case $arg in
      build)
        build
        deploy
        ;;
      deploy)
        deploy
        ;;
      *)
        echo -e "\nUnrecognized argument '$arg'.\n"
        show_usage
        exit -1
    esac
  done
}

if [ $# -eq 0 ]; then
  show_usage
else
  process_args "$@"
fi
