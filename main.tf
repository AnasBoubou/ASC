terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
}

provider "openstack" {
  cloud = "ovh-sbg5"
}
 
resource "openstack_compute_keypair_v2" "main" {
  name       = "my-keypair"
  public_key = file("~/.ssh/id_rsa.pub")
}
 
resource "openstack_compute_instance_v2" "main" {
  name            = "Ahmidou-VM"
  image_name      = "Ubuntu 24.04"
  flavor_name     = "d2-2"
  key_pair        = openstack_compute_keypair_v2.main.name
  security_groups = ["default"]
}

output "instance_ip" {
  description = "IP publique de la VM"
  value       = openstack_compute_instance_v2.main.access_ip_v4
}