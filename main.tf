/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# resource "google_compute_project_metadata" "my_ssh_key" {
#   metadata = {
#     ssh-keys = "${var.remote_user_name}:${file(var.public_key_path)}"
#   }
# }

locals {
  members  = ["serviceAccount:${var.instances_service_account_email}",
  "serviceAccount:owner-sa@education-project-320314.iam.gserviceaccount.com",
  "user:irina.kuzicheva.1984@gmail.com"]
}

data "google_compute_subnetwork" "my-subnetwork" {
  self_link = var.subnet_selflink
}

module "iap_bastion" {
  source  = "./modules/terraform-google-bastion-host"
  project = var.project_id
  zone    = var.zone
  network = data.google_compute_subnetwork.my-subnetwork.network
  subnet  = data.google_compute_subnetwork.my-subnetwork.name
  members = local.members

  access_config = [
    { 
      "nat_ip": "",
      "network_tier": "PREMIUM",
      "public_ptr_domain_name": ""
    }
  ]
  ephemeral_ip = true
  create_firewall_rule = true
  metadata = {
    # ssh-keys = "${var.remote_user_name}:${file(var.public_key_path)}"
  }
}

resource "google_compute_firewall" "allow_access_from_bastion" {
  project = var.project_id
  name    = "allow-bastion-ssh"
  network = data.google_compute_subnetwork.my-subnetwork.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Allow SSH only from IAP Bastion
  source_service_accounts = [module.iap_bastion.service_account]
}
