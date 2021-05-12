variable "project_id" {
  type        = string
  description = "The project ID to host the cluster in (required)"
}

variable "cluster_name" {
  type        = string
  description = "The name for the GKE cluster (required)"
}

variable "gcs_bucket" {
  type        = string
  description = "The GCS bucket name to safe the terraform state files"
}

variable "regional" {
  type        = bool
  description = "Whether is a regional cluster (zonal cluster if set false. WARNING: changing this after cluster creation is destructive!)"
}

variable "region" {
  type        = string
  description = "The region to host the cluster in"
}

variable "zones" {
  type        = list(string)
  description = "The zones to host the cluster in"
}

variable "location" {
  type        = string
  description = "The location where cluster is hosted in"
}

variable "network" {
  type        = string
  description = "The VPC network created to host the cluster in"
}

variable "subnetwork" {
  type        = string
  description = "The subnetwork created to host the cluster in"
}

variable "ip_range_pods_name" {
  type        = string
  description = "The secondary ip range to use for pods"
}

variable "ip_range_services_name" {
  type        = string
  description = "The secondary ip range to use for services"
}

variable "node_pools" {
  type        = object({
    pool_name          = string
    machine_type       = string
    node_locations     = string
    min_count          = number
    max_count          = number
    disk_size_gb       = number
    disk_type          = string
    initial_node_count = number
  })
  description = "Node pools configuration"
}

variable "jwt_secret" {
  type        = string
  description = "JWT_SECRET required variable for backend"
}

variable "mongodb_pass" {
  type        = string
  description = "MongoDB password"
}

variable "image_tag" {
  type        = string
  description = "The tag of the container image to be deployed. This is retrieved automatically by the deploy-app-trigger pipeline"
}

variable "grafana_admin" {
  type        = string
  description = "Grafana admin username"
}

variable "grafana_password" {
  type        = string
  description = "Grafana admin password"
}
