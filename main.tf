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

variable "ssh_public_keys" {
  type    = list(string)
  default = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDzR42jxMW07I/mdGh9lOKRNOHHC+N+Ho+mJ9oC8jnGGcnwdO7/cyayXufXMHkf1wwyFynOliEiDc+tDpBLz4m1Nm7b1xjRMmpdEcy0hlbuZmpC//h4nCQFXfhknO/jEDEd0vtYeUYGNAFXHjELLbrEITl+w6ABeQKd/DWUZHzhpPnwM1/8SqQRGntQQQ4IIrIdCBO1Pkm2EDCrs85XfDdcvExA+SGK4xD0grEHnkAf9+CwILaVBbkOLEAUR47TugkKFotL1TkWcZBRy7w5TFigVRG6cWmi6TkK0Ci9fmCfL9lPU+9Kt5eF+O7PHbsG7SasC1H8MBRMJNZF9lgHYwc/pztMZ+aKh52P334nAwzDX6R8QLkBIkYNlyZHeB3HNQ4aR6tSk2cCZwbCztS+d4bSqkLbXydh4goFueo8tnqNtAaU+Rpe5eojAPH8GMwkVMXA7/mSl+evVxu5+0WaqpH8XZhH/T9MdJp7/PrGRc0Ls5RCcAmC9CyBkE84EbGlT8VFZT9Zo0y2+uHCyoQLg6TxzAE5hf7RwBWQWbhk6MFcm0k7gxhyKIrGhfipIPeg6CtLAirgNRDKJ2jOhkEni32UElkm90H/xVNqFkIdDM0r6PpxIODFqhg8YcAxd7tVf3YzZxeDN0ftkHZtvwnqNDKKxnIvwPL4xUFHQlyJNBgvzw== sanas@AnasB",
  ]
}

# Définition de ta machine virtuelle (Instance)
resource "openstack_compute_instance_v2" "main" {
  name            = "Ahmidou-Anas-v2" # J'ai mis v2 pour forcer la mise à jour
  image_name      = "Ubuntu 24.04"    # À vérifier selon les images dispo
  flavor_name     = "d2-2"            # À vérifier selon ton quota (ex: s1-2, d2-2)
  key_pair        = openstack_compute_keypair_v2.main.name
  security_groups = ["default"]

  network {
    name = "Ext-Net" # Réseau public d'OVH
  }
  # On injecte toutes les clés dans l'utilisateur par défaut
  user_data = <<-EOF
    #cloud-config
    users:
      - name: ubuntu
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_authorized_keys:
          ${indent(10, join("\n", [for key in var.ssh_public_keys : "- ${key}"]))}
  EOF
}

# Affichage de l'IP après la création
output "instance_ip" {
  value = openstack_compute_instance_v2.main.access_ip_v4
}