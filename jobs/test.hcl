job "test" {
  datacenters = ["dc1"]
  type = "service"

  update {
    stagger = "5s"
    max_parallel = 10
  }

  group "web" {
    count = 10
    task "web" {
      service {
        name = "web"
        port = "http"
        tags = [
          "urlprefix-/"
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
        image = "tutum/hello-world"
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
