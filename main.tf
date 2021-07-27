locals {
  num_of_nodes = length (var.boot_disk_images)
}

resource "random_id" "tag" {
  byte_length = 8
}

resource "google_service_account" "bastion" {
  account_id   = "bastion-service-account"
  display_name = "Service Account"
}

resource "null_resource" "build_image" {
  provisioner "local-exec" {
    command = "docker build  -t thedegor/bastion:${random_id.tag.hex} docker/."
  }
  # triggers = {
  #   cluster_instance_ids = join(",", google_compute_instance.bastion.id)
  # }
}

resource "null_resource" "push_image" {
  provisioner "local-exec" {
    command = "docker push thedegor/bastion:${random_id.tag.hex}"
  }
  depends_on = [null_resource.build_image]
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

  provisioner "remote-exec" {
    connection {
            type = "ssh"
            host = self.network_interface.0.access_config.0.nat_ip
            user = var.remote_user
            private_key = file(var.private_key_path)
    } 

    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
      "sudo groupadd docker",
      "sudo usermod -aG docker $USER",
    ]
  }

  provisioner "remote-exec" {
    connection {
            type = "ssh"
            host = self.network_interface.0.access_config.0.nat_ip
            user = var.remote_user
            private_key = file(var.private_key_path)
    } 

    inline = [
      "docker pull thedegor/bastion:${random_id.tag.hex}"
    ]
  }

  depends_on = [null_resource.push_image]
}

output "instance_external_ip" {
  value = join("", formatlist("%s\n", google_compute_instance.bastion[*].network_interface[0].access_config[0].nat_ip))
}

# resource "local_file" "vars" {
#   content = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
#   filename = "${path.module}/ip"
#   file_permission = 0644
# }