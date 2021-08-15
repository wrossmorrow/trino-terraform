
locals {

  location = var.zone == "" ? var.region : var.zone
  is_zonal = var.zone != ""

}

resource "google_container_node_pool" "trino_cluster_pool" {

  for_each = var.node_pools

  name     = "trino-${each.key}"
  location = local.location
  cluster  = var.cluster_name

  initial_node_count = 0

  node_config {
    machine_type    = each.value.machine_type
    disk_size_gb    = each.value.disk_size_gb
    local_ssd_count = each.value.local_ssd_count
    service_account = google_service_account.trino.email

    taint = [{
      key    = "trino"
      value  = "true"
      effect = "NO_EXECUTE"
    }]
    labels = {
      "trino/machine_type" = each.value.machine_type
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

  }

  autoscaling {
    min_node_count = 0
    max_node_count = lookup(each.value, "max_node_count", 10)
  }

  lifecycle {
    ignore_changes = [
      initial_node_count
    ]
  }

}