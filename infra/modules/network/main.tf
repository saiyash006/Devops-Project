terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

resource "docker_network" "public" {
  name   = "${var.env_prefix}-public-net"
  driver = "bridge"
}

resource "docker_network" "private" {
  name   = "${var.env_prefix}-private-net"
  driver = "bridge"
  # Internal true restricts external access, but for basic simulated private network,
  # standard bridge without published ports suffices. We'll leave it as standard bridge.
}
