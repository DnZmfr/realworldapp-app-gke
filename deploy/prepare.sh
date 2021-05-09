#!/usr/bin/env bash

bold() {
  echo "$(tput bold)" "$*" "$(tput sgr0)";
}

TF_VERSION="0.15.0"
GCS_BUCKET="${GOOGLE_CLOUD_PROJECT}-tfstate"

bold "Install terraform v${TF_VERSION}"
mkdir -p "${HOME}/bin"
docker run -v ${HOME}/bin:/software sethvargo/hashicorp-installer terraform "${TF_VERSION}"
sudo chown -R ${USER}: "${HOME}/bin"
chmod 700 "${HOME}/bin/terraform"

bold "Install terraform completion"
${HOME}/bin/terraform -install-autocomplete || true

bold "Create GCS bucket"
gsutil ls gs://${GCS_BUCKET} || gsutil -q mb "gs://${GCS_BUCKET}"

bold "Enable object versioning to keep the history of deployments"
gsutil versioning set on gs://${GCS_BUCKET}
