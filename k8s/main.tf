variable "serviceAccount" {
  type = "string"
}

variable "masterAuthPass" {
  type = "string"
}

provider "google" {
  credentials = "${var.serviceAccount}"
  # change this name 
  project = "jjordan-test"
  region  = "us-east4"
  zone    = "us-east4-a"
}

resource "google_container_cluster" "k8s" {
  name               = "k8s"
  zone               = "us-east4-a"
  initial_node_count = 4

  project = "jjordan-test"

  master_auth {
    username = "test"
    password = "${var.masterAuthPass}"
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels {
      env = "sandbox"
    }

    tags = ["k8s", "se-training", "sandbox"]
  }
}

# The following outputs allow authentication and connectivity to the GKE Cluster.
output "client_certificate" {
  value = "${google_container_cluster.k8s.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.k8s.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.k8s.master_auth.0.cluster_ca_certificate}"
}
