#!/usr/bin/env bash
# creates the mongodb-backup cronjob

kubectl create secret generic gcp-key --from-file=service-account.json=/home/zamfidan/.google/realworld-tf-gke.json
kubectl create -f mongodb-cronjob.yaml
