#!/usr/bin/env bash

bold() {
  echo "$(tput bold)" "$*" "$(tput sgr0)";
}

TF_VERSION="0.15.3"
TF_FILE="terraform_${TF_VERSION}_linux_amd64.zip"
GCS_BUCKET="${GOOGLE_CLOUD_PROJECT}-tfstate"

bold "Install terraform v${TF_VERSION}"
mkdir -p "${HOME}/bin"
wget https://releases.hashicorp.com/terraform/${TF_FILE}
unzip ${TF_FILE} -d ${HOME}/bin/
chmod 700 "${HOME}/bin/terraform"
rm -f ${TF_FILE}

bold "Install terraform completion"
${HOME}/bin/terraform -install-autocomplete || true

bold "Create GCS bucket"
gsutil ls gs://${GCS_BUCKET} || gsutil -q mb "gs://${GCS_BUCKET}"

bold "Enable object versioning to keep the history of deployments"
gsutil versioning set on gs://${GCS_BUCKET}
