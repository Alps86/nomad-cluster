datacenter = "dc1"
data_dir   = "/mnt/nomad"

client {
  enabled = true
  options {
    "docker.auth.config" = "/home/ubuntu/docker_config.json"
  }
}
