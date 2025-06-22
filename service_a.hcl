service {
  name    = "service_a"
  address = "service_a"
  port    = 5000

  connect {
    sidecar_service {}
  }

  check {
    http     = "http://service_a:5000/health"
    interval = "10s"
    timeout  = "5s"
  }
}
