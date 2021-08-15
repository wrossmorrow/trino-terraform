
resource "kubernetes_service" "coordinator" {

  metadata {
    name      = "trino"
    namespace = var.namespace
    labels = {
      app             = "trino"
      trino-release   = var.release
      trino-component = "service"
    }
    annotations = {
      "networking.gke.io/load-balancer-type" = "Internal"
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations
    ]
  }

  spec {

    type             = "LoadBalancer"
    load_balancer_ip = google_compute_address.ingress_ip.address

    selector = {
      app             = "trino"
      trino-release   = var.release
      trino-component = "coordinator"
    }

    port {
      port        = 80
      target_port = 8080
      protocol    = "TCP"
      name        = "http"
    }

    port {
      port        = 443
      target_port = 8443
      protocol    = "TCP"
      name        = "https"
    }

  }

}