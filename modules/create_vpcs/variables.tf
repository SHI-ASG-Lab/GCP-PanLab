# Variables

variable "gcpProject" {
  type = string
}

variable "gcpRegion" {
  type = string
}

variable "gcpZone" {
  type = string
}

variable "labels" {
  type = map(string)
}

variable "tags" {
  type = set(string)
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

variable "customerAbv" {
  type = string
}

variable "projectName" {
  type = string
}
