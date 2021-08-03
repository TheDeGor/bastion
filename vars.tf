variable project_id {
  description = "Project ID where the bastion will run"
  type = string
}
variable zone {
  description = "Zone where they bastion will run"
  type = string
}
variable region {
  description = "Region where the bastion will run"
  type = string
}
variable machine_type {
  type = string
  default = "custom-1-2048"
}
variable boot_disk_images {
  type = list(string)
  default = ["ubuntu-os-cloud/ubuntu-2004-lts"]
  validation {
    condition     = alltrue([
      for entry in var.boot_disk_images : contains(["ubuntu-os-cloud/ubuntu-2004-lts", "debian-cloud/debian-10", "centos-cloud/centos-stream-8"], entry)
    ]) && (length (var.boot_disk_images) != 0)
    error_message = "Three types of images supported: ubuntu-os-cloud/ubuntu-2004-lts, debian-cloud/debian-10, centos-cloud/centos-stream-8."
  }
}
variable public_key_path {
  type = string
}
variable private_key_path {
  type = string
}
variable remote_user {
  type = string
}
variable remote_dir {
  type = string
  default = "/tmp"
}
variable zsh {
  type = bool
  default = true
}
variable terraform {
  type = bool
  default = true
}
variable terraform_version {
  type = string
  default = "1.0.2"
}
variable ansible {
  type = bool
  default = true
}
variable kubectl {
  type = bool
  default = true
}
variable jq {
  type = bool
  default = true
}
variable helm {
  type = bool
  default = true
}
variable sops {
  type = bool
  default = true
}
variable sops_version {
  type = string
  default = "3.7.1"
}
variable k9s {
  type = bool
  default = true
}

variable "subnet_selflink" {
  type = string
  validation {
    condition = var.subnet_selflink != ""
    error_message = "Subnet for bastion-host must be specified."
  }
}

variable "instances_service_account_email" { 
  type = string
}

variable "target_size" {
  description = "Number of instances to create"
  default     = 1
}

variable "remote_user_name" {
  type = string
}