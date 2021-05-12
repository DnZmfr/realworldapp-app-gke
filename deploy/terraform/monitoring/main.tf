terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm       = {
      source  = "hashicorp/helm"
      version = ">= 2.1.2"
    }
  }
  backend "gcs" {
    bucket = "toptal-realworld-app-tfstate"
    prefix = "env/dev/monitoring.tfstate"
  }
}

data "google_client_config" "provider" {}

data "google_container_cluster" "my_cluster" {
  project  = var.project_id
  name     = var.cluster_name
  location = var.location
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.my_cluster.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
  )
}

provider "helm" {
  kubernetes {
    host  = "https://${data.google_container_cluster.my_cluster.endpoint}"
    token = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
    )
  }
}

resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

resource "kubernetes_storage_class" "prometheus-storageclass" {
  metadata {
    name      = "prometheus"
  }

  storage_provisioner = "kubernetes.io/gce-pd"
  reclaim_policy      = "Retain"
  mount_options       = ["debug"]
  parameters          = {
    type   = "pd-standard"
    fstype = "ext4"
  }
}

resource "helm_release" "prometheus" {
  name = "prometheus"
  chart = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  namespace = kubernetes_namespace.prometheus.metadata.0.name
  version = "11.2.1"

  values = [
    file("templates/prometheus-values.yaml")
  ]
}

resource "kubernetes_namespace" "grafana" {
  metadata {
    name = "grafana"
  }
}

resource "helm_release" "grafana" {
  name = "grafana"
  chart = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  namespace = kubernetes_namespace.grafana.metadata.0.name
  depends_on = [helm_release.prometheus]
  version = "~5.0.24"

  values = [
    file("templates/grafana-values.yaml")
  ]

  set {
    name = "adminUser"
    value = var.grafana_admin
  }

  set {
    name = "adminPassword"
    value = var.grafana_password
  }
} 
