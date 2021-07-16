variable project_id {}
variable zone {}
variable region {}
variable machine_type {}
variable boot_disk_images {}
variable public_key_path {}
variable remote_user {}

locals {
  num_of_nodes = length (var.boot_disk_images)
}

resource "google_service_account" "bastion" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_compute_instance" "bastion" {
  count = local.num_of_nodes
  name         = "bastion-${count.index}"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["boot-image"]

  boot_disk {
    initialize_params {
      image = var.boot_disk_images[count.index]
    }
    auto_delete = true
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    ssh-keys = "${var.remote_user}:${file(var.public_key_path)}"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.bastion.email
    scopes = ["cloud-platform"]
  }
}

output "instance_external_ip" {
  value = join("", formatlist("%s\n", google_compute_instance.bastion[*].network_interface[0].access_config[0].nat_ip))
}

# resource "local_file" "vars" {
#   content = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
#   filename = "${path.module}/ip"
#   file_permission = 0644
# }