terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }

  # Configuration du stockage distant (Backend)
  backend "s3" {
    bucket   = "ahmidou-anas"
    key      = "terraform.tfstate"
    region   = "sbg"
    endpoint = "s3.sbg.perf.cloud.ovh.net"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}

# Configuration du fournisseur OVH
provider "openstack" {
  auth_url    = "https://auth.cloud.ovh.net/v3"
  region      = "SBG5" # Vérifie si c'est SBG ou SBG5 selon ton openrc
}

# Création d'une paire de clés SSH (si tu ne l'as pas déjà fait)
resource "openstack_compute_keypair_v2" "main" {
  name = "my-keypair"
}

# Définition de ta machine virtuelle (Instance)
resource "openstack_compute_instance_v2" "main" {
  name            = "Ahmidou-Anas-v2" # J'ai mis v2 pour forcer la mise à jour
  image_name      = "Ubuntu 22.04"    # À vérifier selon les images dispo
  flavor_name     = "d2-2"            # À vérifier selon ton quota (ex: s1-2, d2-2)
  key_pair        = openstack_compute_keypair_v2.main.name
  security_groups = ["default"]

  network {
    name = "Ext-Net" # Réseau public d'OVH
  }
}

# Affichage de l'IP après la création
output "instance_ip" {
  value = openstack_compute_instance_v2.main.access_ip_v4
}