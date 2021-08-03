terraform {
  required_version = ">=0.13"
  required_providers {
    google = {
      source = "hashicorp/google"
      # version = "3.74.0"
    }
    google-beta = {
      source = "hashicorp/google-beta"
      # version = "3.74.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "google" {
  # Configuration options
  project = var.project_id
  region = var.region
  zone = var.zone
}

provider "google-beta" {
  project = var.project_id
  region = var.region
  zone = var.zone
}