/*************************
      GKE
 *************************/

project_id             = "toptal-realworld-app"
cluster_name           = "realworld-cluster"
gcs_bucket             = "toptal-realworld-app-tfstate"
regional               = false
region                 = "us-central1"
zones                  = ["us-central1-c"]
location               = "us-central1-c"
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


/*************************
      APP
 *************************/

jwt_secret             = "Y2U0ZTYwYzIyOTdhZTAxNmVhNjFkZTExNDNhZTdmZDg0ZjNiZTI3Yzc4YzMwYTNhODM5MTAyNjNjMjlhYmU1NTNjZjU0ZjZhN2JmNTExMDA2M2Q0OTkwMWIxNTU4MGRlN2YwZWZiOTEwYmEzZGE3MjhjNWFiNjlkNDZkNWI4Nzg="
mongodb_pass           = "dGVzdA=="
mongodb_uri            = "mongodb://test:test@mongodb.default.svc.cluster.local:27017/test"
image_tag              = ""


/*************************
      MONITORING
 *************************/

grafana_admin          = "admin"
grafana_password       = "test123"
