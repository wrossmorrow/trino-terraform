
resource "kubernetes_horizontal_pod_autoscaler" "workers" {

  metadata {
    name      = "worker"
    namespace = var.namespace
    labels = {
      app             = "trino"
      trino-release   = var.release
      trino-component = "worker"
    }
  }

  spec {

    min_replicas = 3
    max_replicas = 10

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "worker"
    }

    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          average_utilization = 75
          type                = "Utilization"
        }
      }
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          average_utilization = 50
          type                = "Utilization"
        }
      }
    }

  }

}