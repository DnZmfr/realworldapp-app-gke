project_id             = "toptal-realworld-app"
cluster_name           = "realworld-cluster"
regional               = false
region                 = "us-central1"
zones                  = ["us-central1-c"]
network                = "default"
subnetwork             = "default"
ip_range_pods_name     = ""
ip_range_services_name = ""
node_pools             = {
          pool_name          = "default-node-pool"
          machine_type       = "e2-medium"
          node_locations     = "us-central1-c"
          min_count          = 2
          max_count          = 3
          disk_size_gb       = 50
          disk_type          = "pd-standard"
          initial_node_count = 2
}

