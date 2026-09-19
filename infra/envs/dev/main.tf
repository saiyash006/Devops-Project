terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  host = "npipe:////./pipe/docker_engine"
}

module "network" {
  source     = "../../modules/network"
  env_prefix = var.env_prefix
}

module "volumes" {
  source     = "../../modules/volumes"
  env_prefix = var.env_prefix
}

output "public_network_name" {
  value = module.network.public_network_name
}

output "private_network_name" {
  value = module.network.private_network_name
}

output "postgres_volume_name" {
  value = module.volumes.postgres_volume_name
}

output "redis_volume_name" {
  value = module.volumes.redis_volume_name
}
