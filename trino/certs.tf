
locals {
  dns_name = "${var.dns_subdomain}.${data.google_dns_managed_zone.manager.dns_name}"
}

resource "tls_private_key" "key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "cert" {

  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.key.private_key_pem

  subject {
    common_name  = local.dns_name
    organization = "Metromile telematics"
  }

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

data "google_compute_network" "network" {
  name = var.vpc_id
}

data "google_compute_subnetwork" "subnet" {
  name = var.subnet
}

data "google_dns_managed_zone" "manager" {
  name = var.dns_zone
}

resource "google_compute_address" "ingress_ip" {
  name         = "trino-${var.release}-ingress"
  subnetwork   = data.google_compute_subnetwork.subnet.id
  address_type = "INTERNAL"
  region       = "us-central1"
}

resource "google_dns_record_set" "trino" {
  name = local.dns_name
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.manager.name

  rrdatas = [google_compute_address.ingress_ip.address]
}

resource "kubernetes_secret" "tls_cert" {

  metadata {
    name      = "tlscert"
    namespace = var.namespace
    labels = {
      app             = "trino"
      trino-release   = var.release
      trino-component = "coordinator"
    }
  }

  type = "Opaque"

  data = {
    "cert.pem" = <<EOC
${tls_private_key.key.private_key_pem}
${tls_self_signed_cert.cert.cert_pem}
EOC
  }

}