terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version =  "~> 3.42.0"
    }
  }
  backend "gcs" {
    bucket = "toptal-realworld-app-tfstate"
    prefix = "env/dev/gke-cluster.tfstate"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "gke_auth" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  depends_on   = [module.gke]
  project_id   = var.project_id
  location     = module.gke.location
  cluster_name = module.gke.name
}

module "gke" {
  source                 = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id             = var.project_id
  name                   = var.cluster_name
  create_service_account = false
  regional               = var.regional
  region                 = var.region
  zones                  = var.zones
  network                = var.network
  subnetwork             = var.subnetwork
  ip_range_pods          = var.ip_range_pods_name
  ip_range_services      = var.ip_range_services_name
  grant_registry_access  = true
  
  node_pools = [
    {
      name               = var.node_pools.pool_name
      machine_type       = var.node_pools.machine_type
      node_locations     = var.node_pools.node_locations
      min_count          = var.node_pools.min_count
      max_count          = var.node_pools.max_count
      disk_size_gb       = var.node_pools.disk_size_gb
      disk_type          = var.node_pools.disk_type
      initial_node_count = var.node_pools.initial_node_count
    },
  ]
}
