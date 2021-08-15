
locals {

  catalogs = merge({
    "tpch.properties"  = templatefile("${path.module}/config/tpch.properties", {})
    "tpcds.properties" = templatefile("${path.module}/config/tpcds.properties", {})
    }, {
    for k, v in var.catalogs : k => join("\n", [for p, q in v : "${p}=${q}"])
  })

}

resource "kubernetes_config_map" "catalog" {

  metadata {
    name      = "catalog"
    namespace = var.namespace
    labels = {
      app             = "trino"
      trino-release   = var.release
      trino-component = "catalog"
    }
  }

  data = local.catalogs

}