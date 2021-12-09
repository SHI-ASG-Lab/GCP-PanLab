# Configure the cloud provider
terraform {
  required_providers {
      google = {
          source = "google"
          version = ">= 3.73.0"
      }
  }
}

provider "google" {
  project = var.gcpProject
  region  = var.gcpRegion
  zone    = var.gcpZone
}

provider "google-beta" {
  project = var.gcpProject
  region  = var.gcpRegion
  zone    = var.gcpZone
}

# Variable Declarations

variable "gcpProject" {
  type = string
}
variable "gcpRegion" {
  type = string
}
variable "gcpZone" {
  type = string
}
variable "customerAbv" {
  type = string
}
variable "subnet_cidr1" {
  type = string
}
variable "subnet_cidr2" {
  type = string
}
variable "panint1" {
  type = string
}
variable "panint2" {
  type = string
}

# Locals

locals {
  fg1Labels = {
    owner = "mwheeler"
    sp    = "lab"
  }
  netTags = ["panlab1"]
}

## Resources ##

# Networks

data "google_compute_network" "default" {
  name    = "default"
  project = var.gcpProject
}

data "google_compute_subnetwork" "default" {
  name    = "default"
  project = var.gcpProject
}

module "create_vpcs" {
  source = "./modules/create_vpcs"

  gcpProject = var.gcpProject
  gcpRegion = var.gcpRegion
  gcpZone = var.gcpZone

  labels = local.fg1Labels
  tags  = local.netTags

  subnet_cidr1 = var.subnet_cidr1
  subnet_cidr2 = var.subnet_cidr2
  panint1 = var.panint1
  panint2 = var.panint2
  customerAbv = var.customerAbv
  projectName = "panlab-${var.customerAbv}"
}

# PanNGFW-StrataVM

data "google_compute_image" "pan-ngfw" {
  name    = "panlab-ngfw-image1"
  project = var.gcpProject
}

resource "google_compute_disk" "panvm-1-disk" {
  name = "panlab-${var.customerAbv}-panvm-1-disk"
  description = "OS disk made from image"
  image = data.google_compute_image.pan-ngfw.self_link
  zone = var.gcpZone
}

resource "google_compute_address" "panvm-1-ip" {
  name = "panlab-${var.customerAbv}-ext-panvm-1-ip"
  address_type = "EXTERNAL"
}

resource "google_compute_address" "panvm-2-ip" {
  name = "panlab-${var.customerAbv}-ext-panvm-2-ip"
  address_type = "EXTERNAL"
}

resource "google_compute_address" "panvm-3-ip" {
  name = "panlab-${var.customerAbv}-ext-panvm-3-ip"
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "panvm-1" {
  project      = var.gcpProject
  name         = "panlab-${var.customerAbv}-panngfw-vm"
  machine_type = "n1-standard-8"
  zone         = var.gcpZone
  boot_disk {
    source     = google_compute_disk.panvm-1-disk.self_link
  }
  network_interface {
    network    = data.google_compute_network.default.self_link
    subnetwork = data.google_compute_subnetwork.default.self_link
    access_config {
      nat_ip = google_compute_address.panvm-1-ip.address
    }  
  }
  network_interface {
    network    = module.create_vpcs.nw1
    subnetwork = module.create_vpcs.sn1
    network_ip = var.panint1
    access_config {
      nat_ip = google_compute_address.panvm-2-ip.address
    }
  }
  network_interface {
    network    = module.create_vpcs.nw2
    subnetwork = module.create_vpcs.sn2
    network_ip = var.panint2
    access_config {
      nat_ip = google_compute_address.panvm-3-ip.address
    }
  }
  labels = local.fg1Labels
  tags  = local.netTags
}
