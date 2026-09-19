terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

resource "docker_volume" "postgres_data" {
  name = "${var.env_prefix}-postgres-data"
}

resource "docker_volume" "redis_data" {
  name = "${var.env_prefix}-redis-data"
}

resource "docker_volume" "grafana_data" {
  name = "${var.env_prefix}-grafana-data"
}
