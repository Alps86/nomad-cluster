job "hello-world" {
  datacenters = ["dc1"]
  type = "service"

  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "hello-world" {
    count = 2
    task "hello-world" {

      service {
        name = "hello-world"
        port = "http"
        tags = [
          "urlprefix-/"]
        check {
          type = "http"
          port = "80"
          interval = "15s"
          timeout = "5s"
          path = "http://127.0.0.1:80"
        }
      }
      driver = "docker"
      config {
        port_map {
          http = 80
        }
        image = "tutum/hello-world"
        network_mode = "host"
      }

      resources {
        cpu = 500
        memory = 64
        network {
          mbits = 1

          port "http" {
            static = "80"
          }
        }
      }
    }
  }
}