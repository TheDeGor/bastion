variable project_id {
  type = string
}
variable zone {
  type = string
}
variable region {
  type = string
}
variable machine_type {
  type = string
  default = "custom-1-2048"
}
variable boot_disk_images {
  type = list(string)
  default = ["ubuntu-os-cloud/ubuntu-2010"]
  validation {
    condition     = alltrue([
      for entry in var.boot_disk_images : contains(["ubuntu-os-cloud/ubuntu-2004-lts"], entry)
    ]) && (length (var.boot_disk_images) != 0)
    error_message = "Three types of images supported: ubuntu-os-cloud/ubuntu-2004-lts."
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