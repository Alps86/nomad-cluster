job "php" {
  datacenters = ["dc1"]
  type = "service"

  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "stack" {
    count = 1
    task "data" {
      driver = "docker"
      config {
        volumes = [
          "../code:/code"
        ]
        image = "xxxxxxxxxxxxx.amazonaws.com/data:latest"
      }
    },
    task "nginx" {
      service {
        name = "${TASKGROUP}-nginx"
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
        volumes = [
          "../code:/code"
        ]
        port_map {
          http = 80
        }
        image = "xxxxxxxxxxxxx.amazonaws.com/nginx:latest"
      }

      env = {
        FPM_UPSTREAM = "${NOMAD_ADDR_fpm_fpm}"
      }

      resources {
        cpu = 100
        memory = 32
        network {
          mbits = 1
          port "http" {}
        }
      }
    },
    task "fpm" {
      service {
        name = "${TASKGROUP}-fpm"
      }

      driver = "docker"
      config {
        volumes = [
          "../code:/code"
        ]
        port_map {
          fpm = 9000
        }
        image = "xxxxxxxxxxxxx.amazonaws.com/fpm:latest"
      }

      resources {
        cpu = 100
        memory = 32
        network {
          mbits = 1
          port "fpm" {}
        }
      }
    }
  }
}
