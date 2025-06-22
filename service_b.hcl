service {
  name    = "service_b"
  address = "service_b"
  port    = 5001

  connect {
    sidecar_service {
      proxy {
        upstreams = [
          {
            destination_name = "service_a"
            local_bind_port  = 8080
          }
        ]
      }
    }
  }

  check {
    http     = "http://service_b:5001/health"
    interval = "10s"
    timeout  = "5s"
  }
}
