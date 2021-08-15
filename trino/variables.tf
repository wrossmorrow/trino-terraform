
variable "region" {
  description = "Google Cloud Region"
  type        = string
}

variable "zone" {
  description = "Google Cloud Zone, will create regional resources if not set."
  type        = string
}

variable "vpc_id" {
  description = "Google Cloud VPC ID, will be created if not set."
  type        = string
}

variable "subnet" {
  description = "Subnet/Subnetwork we are running in."
  type        = string
}

variable "cluster_name" {
  description = "The cluster to launch into"
  type        = string
}

variable "node_pools" {
  type = map(any)
  default = {
    default = { machine_type = "c2-standard-4", disk_size_gb = 20, local_ssd_count = 0 }
  }
}

variable "namespace" {
  description = "Namespace to use for trino deployment(s)"
  type        = string
  default     = "trino"
}

variable "release" {
  description = "Trino release version"
  type        = string
  default     = "359"
}

variable "catalogs" {
  description = "Trino catalogs"
  type        = map(any)
  default     = {}
}

variable "rules" {
  description = "Trino access controls"
  type        = map(any)
}

variable "dns_zone" {
  type = string
}

variable "dns_subdomain" {
  type    = string
  default = "trino"
}