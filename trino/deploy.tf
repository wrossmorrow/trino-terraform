
locals {

  coord_node_pool_key  = contains(keys(var.node_pools), "coordinator") ? "coordinator" : "default"
  coord_node_pool_name = google_container_node_pool.trino_cluster_pool[local.coord_node_pool_key].name

  worker_node_pool_key  = contains(keys(var.node_pools), "worker") ? "worker" : "default"
  worker_node_pool_name = google_container_node_pool.trino_cluster_pool[local.worker_node_pool_key].name

}

resource "kubernetes_deployment" "coordinator" {

  metadata {
    name      = "coordinator"
    namespace = var.namespace
    labels = {
      app             = "trino"
      trino-release   = var.release
      trino-component = "coordinator"
    }
  }

  lifecycle {
    ignore_changes = [
      spec[0].replicas
    ]
  }

  spec {

    replicas = 1

    selector {
      match_labels = {
        app             = "trino"
        trino-release   = var.release
        trino-component = "coordinator"
      }
    }

    template {

      metadata {
        labels = {
          app             = "trino"
          trino-release   = var.release
          trino-component = "coordinator"
        }
      }

      spec {

        # link KSA to GSA
        # service_account_name = kubernetes_service_account.trino.metadata[0].name

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.coordinator.metadata[0].name
          }
        }

        volume {
          name = "catalog"
          config_map {
            name = kubernetes_config_map.catalog.metadata[0].name
          }
        }

        volume {
          name = "certs"
          secret {
            secret_name = kubernetes_secret.tls_cert.metadata[0].name
          }
        }

        volume {
          name = "access-control"
          config_map {
            name = kubernetes_config_map.access_control.metadata[0].name
          }
        }

        node_selector = {
          "cloud.google.com/gke-nodepool" = local.coord_node_pool_name
        }

        toleration {
          effect   = "NoExecute"
          key      = "trino"
          operator = "Exists"
        }

        container {
          image             = "trinodb/trino:${var.release}"
          name              = "trino-coordinator"
          image_pull_policy = "IfNotPresent"

          resources {
            limits = {
              cpu    = "1500m"
              memory = "2048Mi"
            }
            requests = {
              cpu    = "1000m"
              memory = "1024Mi"
            }
          }

          security_context {
            run_as_user  = 1000
            run_as_group = 1000
          }

          volume_mount {
            mount_path = "/etc/trino"
            name       = "config"
          }

          volume_mount {
            mount_path = "/etc/trino/catalog"
            name       = "catalog"
          }

          volume_mount {
            mount_path = "/etc/trino/tls"
            name       = "certs"
          }

          volume_mount {
            mount_path = "/etc/trino/access-control"
            name       = "access-control"
          }

        }

      }

    }

  }

}


resource "kubernetes_deployment" "worker" {

  metadata {
    name      = "worker"
    namespace = var.namespace
    labels = {
      app             = "trino"
      trino-release   = var.release
      trino-component = "worker"
    }
  }

  lifecycle {
    ignore_changes = [
      spec[0].replicas
    ]
  }

  spec {

    replicas = 3

    selector {
      match_labels = {
        app             = "trino"
        trino-release   = var.release
        trino-component = "worker"
      }
    }

    template {

      metadata {
        labels = {
          app             = "trino"
          trino-release   = var.release
          trino-component = "worker"
        }
      }

      spec {

        # link KSA to GSA
        # service_account_name = kubernetes_service_account.trino.metadata[0].name

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.worker.metadata[0].name
          }
        }

        volume {
          name = "catalog"
          config_map {
            name = kubernetes_config_map.catalog.metadata[0].name
          }
        }

        volume {
          name = "certs"
          secret {
            secret_name = kubernetes_secret.tls_cert.metadata[0].name
          }
        }

        volume {
          name = "access-control"
          config_map {
            name = kubernetes_config_map.access_control.metadata[0].name
          }
        }

        node_selector = {
          "cloud.google.com/gke-nodepool" = local.coord_node_pool_name
        }

        toleration {
          effect   = "NoExecute"
          key      = "trino"
          operator = "Exists"
        }

        container {
          image             = "trinodb/trino:${var.release}"
          name              = "trino-worker"
          image_pull_policy = "IfNotPresent"

          resources {
            limits = {
              cpu    = "1500m"
              memory = "2048Mi"
            }
            requests = {
              cpu    = "1000m"
              memory = "1024Mi"
            }
          }

          security_context {
            run_as_user  = 1000
            run_as_group = 1000
          }

          volume_mount {
            mount_path = "/etc/trino"
            name       = "config"
          }

          volume_mount {
            mount_path = "/etc/trino/catalog"
            name       = "catalog"
          }

          volume_mount {
            mount_path = "/etc/trino/tls"
            name       = "certs"
          }

          volume_mount {
            mount_path = "/etc/trino/access-control"
            name       = "access-control"
          }

        }

      }

    }

  }

}