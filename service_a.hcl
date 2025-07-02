service {
  name    = "service-a"
  address = "service-a"
  port    = 5000

  check {
    args = [
      "curl",
      "-fsS",
      "--cert", "/consul/certs/service_b.pem",
      "--key", "/consul/certs/service_b-key.pem",
      "--cacert", "/consul/certs/ca.pem",
      "https://service_a:5000/health"
    ]
    interval = "10s"
    timeout  = "5s"
  }
}
