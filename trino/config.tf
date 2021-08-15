
resource "kubernetes_config_map" "worker" {

  metadata {
    name      = "worker"
    namespace = var.namespace
    labels = {
      app             = "trino"
      trino-release   = var.release
      trino-component = "worker"
    }
  }

  data = {
    "config.properties" = templatefile("${path.module}/config/worker-config.properties", {})
    "jvm.config"        = templatefile("${path.module}/config/worker-jvm-config.properties", {})
    "log.properties"    = templatefile("${path.module}/config/log-config.properties", {})
    "node.properties"   = templatefile("${path.module}/config/node-config.properties", {})
  }

}

resource "kubernetes_config_map" "coordinator" {

  metadata {
    name      = "coordinator"
    namespace = var.namespace
    labels = {
      app             = "trino"
      trino-release   = var.release
      trino-component = "corrdinator"
    }
  }

  data = {
    "config.properties" = templatefile("${path.module}/config/coord-config.properties", {})
    "jvm.config"        = templatefile("${path.module}/config/coord-jvm-config.properties", {})
    "log.properties"    = templatefile("${path.module}/config/log-config.properties", {})
    "node.properties"   = templatefile("${path.module}/config/node-config.properties", {})
  }

}

resource "kubernetes_config_map" "access_control" {

  metadata {
    name      = "access-control"
    namespace = var.namespace
    labels = {
      app             = "trino"
      trino-release   = var.release
      trino-component = "access-control"
    }
  }

  data = {
    "rules.json" = jsonencode(var.rules)
  }

}