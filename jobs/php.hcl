job "php" {
  datacenters = ["dc1"]
  type = "service"

  update {
    stagger = "5s"
    max_parallel = 10
  }

  group "web" {
    count = 1
    task "web" {
      service {
        name = "web"
        port = "http"
        tags = [
          "urlprefix-/test"
        ]
        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
      driver = "docker"
      config {
        port_map {
          http = 80
        }
        image = "xxxxxxxxxxxx.amazonaws.com/test:latest"
      }

      resources {
        cpu = 100
        memory = 64
        network {
          mbits = 1
          port "http" {}
        }
      }
    }
  }
}
