locals {
  num_of_nodes = length (var.boot_disk_images)
}

# resource "google_service_account" "bastion" {
#   account_id   = "bastion-service-account"
#   display_name = "Service Account"
# }

module "startup-script-lib" {
  source = "git::https://github.com/terraform-google-modules/terraform-google-startup-scripts.git?ref=v0.1.0"
}

data "template_file" "startup_script_config" {
  template = "${file("${path.module}/templates/startup-script-config.tpl")}"
  vars = {
    zsh="${var.zsh}"
    terraform="${var.terraform}"
    terraform_version="${var.terraform_version}"
    ansible="${var.ansible}"
    kubectl="${var.kubectl}"
    jq="${var.jq}"
    helm="${var.helm}"
    sops="${var.sops}"
    sops_version="${var.sops_version}"
    k9s="${var.k9s}"
  }
}

module "iap_bastion" {
  source = "terraform-google-modules/bastion-host/google"

  project = var.project_id
  zone    = var.zone
  network = var.network_selflink
  subnet  = var.subnet_selflink
  # members = [
  #   google_service_account.bastion.id,
  # ]
  access_config = [
    {
      nat_ip=null,
      network_tier = "STANDARD",
      public_ptr_domain_name = ""
    }
  ]
  create_firewall_rule = true
  create_instance_from_template = true
  disk_size_gb = 10
  disk_type = "pd-standard"
  ephemeral_ip = true
  fw_name_allow_ssh_from_iap = "fwd-ssh-to-instances"
  host_project = var.project_id
  image_project = "ubuntu-os-cloud"
  image_family = "ubuntu-2004-lts"
  machine_type = var.machine_type
  metadata = {
    ssh-keys = "${var.remote_user}:${file(var.public_key_path)}"
    startup-script-config = data.template_file.startup_script_config.rendered
    startup-script-custom = "${file("${path.module}/bastion/bastion_install.sh")}"
  }
  # service_account_email = "google_service_account.bastion.email"
  service_account_roles = [ "roles/logging.logWriter", "roles/monitoring.metricWriter", "roles/monitoring.viewer", "roles/compute.osLogin" ]


}




# resource "google_compute_instance" "bastion" {
#   count = local.num_of_nodes
#   name         = "bastion-${count.index}"
#   machine_type = var.machine_type
#   zone         = var.zone

#   tags = ["boot-image"]

#   boot_disk {
#     initialize_params {
#       image = var.boot_disk_images[count.index]
#     }
#     auto_delete = true
#   }

#   network_interface {
#     network = "default"

#     access_config {
#       // Ephemeral IP
#     }
#   }

#   metadata = {
#     ssh-keys = "${var.remote_user}:${file(var.public_key_path)}"
#   }

#   metadata_startup_script = "echo hi > /test.txt"

#   service_account {
#     # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
#     email  = google_service_account.bastion.email
#     scopes = ["cloud-platform"]
#   }

#   provisioner "file" {
#     connection {
#             type = "ssh"
#             host = self.network_interface.0.access_config.0.nat_ip
#             user = var.remote_user
#             private_key = file(var.private_key_path)
#     }
#     source      = "bastion/bastion_install.sh"
#     destination = "${var.remote_dir}/bastion_install.sh"
#   }
  
#   provisioner "file" {
#     connection {
#             type = "ssh"
#             host = self.network_interface.0.access_config.0.nat_ip
#             user = var.remote_user
#             private_key = file(var.private_key_path)
#     }
#     source      = "bastion/.zshrc"
#     destination = "${var.remote_dir}/.zshrc"
#   }

#   provisioner "file" {
#     connection {
#             type = "ssh"
#             host = self.network_interface.0.access_config.0.nat_ip
#             user = var.remote_user
#             private_key = file(var.private_key_path)
#     }
#     source      = "bastion/.p10k.zsh"
#     destination = "${var.remote_dir}/.p10k.zsh"
#   }

#   provisioner "remote-exec" {
#     connection {
#             type = "ssh"
#             host = self.network_interface.0.access_config.0.nat_ip
#             user = var.remote_user
#             private_key = file(var.private_key_path)
#     } 

#     inline = [
#       "export ZSH=${var.zsh}",
#       "export TERRAFORM=${var.terraform}",
#       "export TERRAFORM_VER=${var.terraform_version}",
#       "export ANSIBLE=${var.ansible}",
#       "export KUBECTL=${var.kubectl}",
#       "export JQ=${var.jq}",
#       "export HELM=${var.helm}",
#       "export SOPS=${var.sops}",
#       "export SOPS_VER=${var.sops_version}",
#       "export K9S=${var.k9s}",
#       "export INSTALL_DIR=${var.remote_dir}",
#       "chmod +x ${var.remote_dir}/bastion_install.sh",
#       "${var.remote_dir}/bastion_install.sh",
#     ]
#   }
# }

# output "instance_external_ip" {
#   value = join("", formatlist("%s\n", google_compute_instance.bastion[*].network_interface[0].access_config[0].nat_ip))
# }

# resource "local_file" "vars" {
#   content = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
#   filename = "${path.module}/ip"
#   file_permission = 0644
# }