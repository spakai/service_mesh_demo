service {
  name    = "service_a"
  address = "service_a"
  port    = 5000

  check {
    http            = "https://service_a:5000/health"
    interval        = "10s"
    timeout         = "5s"
    tls_skip_verify = true
  }
}
