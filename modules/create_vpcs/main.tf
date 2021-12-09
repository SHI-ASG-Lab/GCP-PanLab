# Create VPC for Network1
resource "google_compute_network" "vpc1" {
 name                    = "${var.projectName}-1-net"
 auto_create_subnetworks = false
}

output "nw1" {
 value = google_compute_network.vpc1.self_link
}

# Create Subnet for Network1
resource "google_compute_subnetwork" "subn1" {
 name          = "${var.projectName}-1-sn"
 ip_cidr_range = var.subnet_cidr1
 network       = google_compute_network.vpc1.self_link
 region        = var.gcpRegion
}

 output "sn1" {
 value = google_compute_subnetwork.subn1.self_link
}

  # Create VPC for Network2
resource "google_compute_network" "vpc2" {
 name                    = "${var.projectName}-2-net"
 auto_create_subnetworks = false
}

output "nw2" {
 value = google_compute_network.vpc2.self_link
}

# Create Subnet for Network2
resource "google_compute_subnetwork" "subn2" {
 name          = "${var.projectName}-2-sn" 
 ip_cidr_range = var.subnet_cidr2
 network       = google_compute_network.vpc2.self_link
 region        = var.gcpRegion
}

 output "sn2" {
 value = google_compute_subnetwork.subn2.self_link
}

# VPC1 firewall configuration
resource "google_compute_firewall" "firewall1" {
  name    = "${var.projectName}-firewall"
  network = google_compute_network.vpc1.self_link

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  source_ranges = ["0.0.0.0/0"]
}

# VPC2 firewall configuration
resource "google_compute_firewall" "firewall2" {
  name    = "${var.projectName}-firewall2"
  network = google_compute_network.vpc2.self_link

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  source_ranges = ["0.0.0.0/0"]
}

#Routes
resource "google_compute_route" "pannw1to2" {
  name        = "${var.projectName}-pannw1to2"
  dest_range  = var.subnet_cidr2
  network     = google_compute_network.vpc1.self_link
  next_hop_ip = var.panint1
  priority    = 100
  #added depends_on because the route must be created after the subnet
  depends_on = [
    google_compute_subnetwork.subn1,
  ]
}

resource "google_compute_route" "pannw2to1" {
  name        = "${var.projectName}-pannw2to1"
  dest_range  = var.subnet_cidr1
  network     = google_compute_network.vpc2.self_link
  next_hop_ip = var.panint2
  priority    = 100
  #added depends_on because the route must be created after the subnet
  depends_on = [
    google_compute_subnetwork.subn2,
  ]
}
