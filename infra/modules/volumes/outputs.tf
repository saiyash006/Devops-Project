output "postgres_volume_name" {
  value = docker_volume.postgres_data.name
}

output "redis_volume_name" {
  value = docker_volume.redis_data.name
}

output "grafana_volume_name" {
  value = docker_volume.grafana_data.name
}
