server = true
bootstrap = true
ui = true
client_addr = "0.0.0.0"

ports {
  http = -1
  https = 8501
}

key_file = "/consul/certs/consul-server-key.pem"
cert_file = "/consul/certs/consul-server.pem"
ca_file = "/consul/certs/ca.pem"

verify_incoming = true
verify_outgoing = true
verify_server_hostname = true
verify_incoming_https = true
