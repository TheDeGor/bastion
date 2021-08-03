locals {
  num_of_nodes = length (var.boot_disk_images)
}

resource "google_compute_project_metadata" "ssh_keys" {
    metadata {
      ssh-keys = "${var.remote_user}:${file(var.public_key_path)}"
    }
}

resource "google_service_account" "bastion" {
  account_id   = "bastion-service-account"
  display_name = "Service Account"
}

resource "google_compute_instance" "bastion" {
  count = local.num_of_nodes
  name         = "bastion-${count.index}"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["bastion"]

  boot_disk {
    initialize_params {
      image = var.boot_disk_images[count.index]
    }
    auto_delete = true
  }

  network_interface {
    network = var.network_selflink
    subnetwork = var.subnet_selflink

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    block-project-ssh-keys = false 
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.bastion.email
    scopes = ["cloud-platform"]
  }

  provisioner "file" {
    connection {
            type = "ssh"
            host = self.network_interface.0.access_config.0.nat_ip
            user = var.remote_user
            private_key = file(var.private_key_path)
    }
    source      = "bastion/bastion_install.sh"
    destination = "${var.remote_dir}/bastion_install.sh"
  }
  
  provisioner "file" {
    connection {
            type = "ssh"
            host = self.network_interface.0.access_config.0.nat_ip
            user = var.remote_user
            private_key = file(var.private_key_path)
    }
    source      = "bastion/.zshrc"
    destination = "${var.remote_dir}/.zshrc"
  }

  provisioner "file" {
    connection {
            type = "ssh"
            host = self.network_interface.0.access_config.0.nat_ip
            user = var.remote_user
            private_key = file(var.private_key_path)
    }
    source      = "bastion/.p10k.zsh"
    destination = "${var.remote_dir}/.p10k.zsh"
  }

  provisioner "remote-exec" {
    connection {
            type = "ssh"
            host = self.network_interface.0.access_config.0.nat_ip
            user = var.remote_user
            private_key = file(var.private_key_path)
    } 

    inline = [
      "export ZSH=${var.zsh}",
      "export TERRAFORM=${var.terraform}",
      "export TERRAFORM_VER=${var.terraform_version}",
      "export ANSIBLE=${var.ansible}",
      "export KUBECTL=${var.kubectl}",
      "export JQ=${var.jq}",
      "export HELM=${var.helm}",
      "export SOPS=${var.sops}",
      "export SOPS_VER=${var.sops_version}",
      "export K9S=${var.k9s}",
      "export INSTALL_DIR=${var.remote_dir}",
      "chmod +x ${var.remote_dir}/bastion_install.sh",
      "${var.remote_dir}/bastion_install.sh",
    ]
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

# firewall rule and iap