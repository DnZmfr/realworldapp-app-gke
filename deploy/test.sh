#!/usr/bin/env bash

CHECK_PVC=$(kubectl get pvc| grep mongodb-volume-claim| wc -l)
if [ ${CHECK_PVC} -eq 0 ]; then
  echo "kubectl create pvc"
fi

