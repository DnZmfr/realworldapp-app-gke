variable "credentials" {
  type        = string
  description = "Location of json credentials file"
}

variable "project_id" {
  type        = string
  description = "The project ID to host the cluster in (required)"
}

variable "cluster_name" {
  type        = string
  description = "The name for the GKE cluster (required)"
}

variable "regional" {
  type        = bool
  description = "Whether is a regional cluster (zonal cluster if set false. WARNING: changing this after cluster creation is destructive!)"
}

variable "region" {
  type        = string
  description = "The region to host the cluster in"
}

variable "zone" {
  type        = string
  description = "The zone to host the cluster in"
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
