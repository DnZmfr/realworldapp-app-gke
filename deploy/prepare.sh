#!/usr/bin/env bash

boldn() {
  echo -n ". $(tput bold)" "$*" "$(tput sgr0)";
}

bold() {
  echo "$(tput bold)" "$*" "$(tput sgr0)";
}

TF_VERSION="0.15.3"
TF_FILE="terraform_${TF_VERSION}_linux_amd64.zip"
GCS_BUCKET="${GOOGLE_CLOUD_PROJECT}-tfstate"
SERVICE_ACCOUNT="realworld-tf-gke"

bold "Install terraform v${TF_VERSION}..."
mkdir -p "${HOME}/bin"
wget https://releases.hashicorp.com/terraform/${TF_FILE}
unzip ${TF_FILE} -d ${HOME}/bin/
chmod 700 "${HOME}/bin/terraform"
${HOME}/bin/terraform -install-autocomplete || true
rm -f ${TF_FILE}

bold "Configure gcloud and enable required APIs..."
gcloud config set project ${GOOGLE_CLOUD_PROJECT}
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud config set compute/zone us-central1-c
gcloud config set compute/region us-central1

bold "Grant required deployment permissions to cloud build service account..."
CLOUDBUILD_SA="$(gcloud projects describe ${GOOGLE_CLOUD_PROJECT} --format 'value(projectNumber)')@cloudbuild.gserviceaccount.com"
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} --member serviceAccount:${CLOUDBUILD_SA} --role="roles/editor"
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} --member serviceAccount:${CLOUDBUILD_SA} --role="roles/compute.viewer"
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} --member serviceAccount:${CLOUDBUILD_SA} --role="roles/container.clusterAdmin"
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} --member serviceAccount:${CLOUDBUILD_SA} --role="roles/container.developer"
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} --member serviceAccount:${CLOUDBUILD_SA} --role="roles/iam.serviceAccountAdmin"
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} --member serviceAccount:${CLOUDBUILD_SA} --role="roles/iam.serviceAccountUser"
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} --member serviceAccount:${CLOUDBUILD_SA} --role="roles/resourcemanager.projectIamAdmin"

boldn "Create service account and grant permissions to GCS..."
CHECK_SA_USER=$(gcloud iam service-accounts list| grep ${SERVICE_ACCOUNT}@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com| wc -l)
if [ ${CHECK_SA_USER} -eq 0 ]; then
  gcloud iam service-accounts create ${SERVICE_ACCOUNT} --description="Service Account for Terraform deployments" --display-name="RealWorld Terraform GKE"
  gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} --member="serviceAccount:${SERVICE_ACCOUNT}@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" --role="roles/storage.objectAdmin"
  bold "Done."
else
  bold "skipping, already exists."
fi
boldn "Generate service account key..."
CHECK_SA_KEY=$(gcloud iam service-accounts keys list --iam-account=${SERVICE_ACCOUNT}@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com --managed-by=user --format text| wc -l)
if [ ${CHECK_SA_KEY} -eq 0 ]; then
  mkdir -p ${HOME}/.google/
  gcloud iam service-accounts keys create ${HOME}/.google/${SERVICE_ACCOUNT}.json --iam-account=${SERVICE_ACCOUNT}@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com
  bold "Done."
else
  bold "skipping, key already exists."
fi

boldn "Create pubsub topic for automated builds..."
CHECK_PUBSUB_TOPIC=$(gcloud pubsub topics list| grep gcr| wc -l)
if [ ${CHECK_PUBSUB_TOPIC} -eq 0 ]; then
  gcloud pubsub topics create gcr --project=${GOOGLE_CLOUD_PROJECT}
  bold "Done."
else
  bold "skipping, gcr pubsub topic already exists."
fi

bold "Create GCS bucket"
gsutil ls gs://${GCS_BUCKET} || gsutil -q mb "gs://${GCS_BUCKET}"

bold "Enable object versioning to keep the history of deployments"
gsutil versioning set on gs://${GCS_BUCKET}

