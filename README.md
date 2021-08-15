
# Introduction

This repo contains [`terraform`](https://terraform.io/) templates for deploying [`trino`](https://trino.io/) into `kubernetes`. `trino` publishes a `helm` chart ([here](https://github.com/trinodb/charts)), but these are reasonably hard to customize. Alot of infrastructure is managed in `terraform` anyway, so why not have a native module? 

Currently for GCP/GKE. Maybe I'll get to an AWS version. 

# Quick Start

Meant to be used like a module. Here's a sketch from an actual use in real infrastructure: 

```
module "trino_cluster" {

  source = "../utilities/trino"

  depends_on = [
    kubernetes_namespace.trino
  ]

  providers = {
    google     = google
    kubernetes = kubernetes
  }

  region = var.google_cloud_region
  zone   = var.google_cloud_zone
  vpc_id = var.google_cloud_network
  subnet = var.google_cloud_subnetwork

  dns_zone      = var.trino_dns_zone
  dns_subdomain = var.trino_subdomain

  cluster_name = var.cluster_name

  namespace = var.trino_namespace

  rules = var.trino_access_rules

  catalogs = {
    "mongodb.properties" = {
        ...
    }
    "druiddb.properties" = {
        ...
    }
  }

}

```
