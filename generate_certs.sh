#!/bin/bash
set -e
CERT_DIR="certs"
mkdir -p "$CERT_DIR"

# Generate CA
openssl genrsa -out "$CERT_DIR/ca-key.pem" 2048
openssl req -x509 -new -nodes -key "$CERT_DIR/ca-key.pem" \
  -days 3650 -out "$CERT_DIR/ca.pem" -subj "/CN=Demo CA"

# Consul certificate config
cat > "$CERT_DIR/consul.cnf" <<EOC
[req]
distinguished_name=req
default_md = sha256
req_extensions=v3_req
[req_distinguished_name]
[v3_req]
subjectAltName=@alt_names
[alt_names]
DNS.1=localhost
DNS.2=server.dc1.consul
IP.1=127.0.0.1
EOC

# Service A certificate config
cat > "$CERT_DIR/service_a.cnf" <<EOC
[req]
distinguished_name=req
default_md = sha256
req_extensions=v3_req
[req_distinguished_name]
[v3_req]
subjectAltName=@alt_names
[alt_names]
DNS.1=localhost
DNS.2=service_a
IP.1=127.0.0.1
EOC

# Service B certificate config
cat > "$CERT_DIR/service_b.cnf" <<EOC
[req]
distinguished_name=req
default_md = sha256
req_extensions=v3_req
[req_distinguished_name]
[v3_req]
subjectAltName=@alt_names
[alt_names]
DNS.1=localhost
DNS.2=service_b
IP.1=127.0.0.1
EOC

# Consul server certificate
openssl genrsa -out "$CERT_DIR/consul-server-key.pem" 2048
openssl req -new -key "$CERT_DIR/consul-server-key.pem" -out "$CERT_DIR/consul-server.csr" \
  -subj "/CN=consul-server" -config "$CERT_DIR/consul.cnf"
openssl x509 -req -in "$CERT_DIR/consul-server.csr" -CA "$CERT_DIR/ca.pem" \
  -CAkey "$CERT_DIR/ca-key.pem" -CAcreateserial -out "$CERT_DIR/consul-server.pem" \
  -days 825 -extensions v3_req -extfile "$CERT_DIR/consul.cnf"

# Service A certificate
openssl genrsa -out "$CERT_DIR/service_a-key.pem" 2048
openssl req -new -key "$CERT_DIR/service_a-key.pem" -out "$CERT_DIR/service_a.csr" \
  -subj "/CN=service_a" -config "$CERT_DIR/service_a.cnf"
openssl x509 -req -in "$CERT_DIR/service_a.csr" -CA "$CERT_DIR/ca.pem" \
  -CAkey "$CERT_DIR/ca-key.pem" -CAcreateserial -out "$CERT_DIR/service_a.pem" \
  -days 825 -extensions v3_req -extfile "$CERT_DIR/service_a.cnf"

# Service B certificate
openssl genrsa -out "$CERT_DIR/service_b-key.pem" 2048
openssl req -new -key "$CERT_DIR/service_b-key.pem" -out "$CERT_DIR/service_b.csr" \
  -subj "/CN=service_b" -config "$CERT_DIR/service_b.cnf"
openssl x509 -req -in "$CERT_DIR/service_b.csr" -CA "$CERT_DIR/ca.pem" \
  -CAkey "$CERT_DIR/ca-key.pem" -CAcreateserial -out "$CERT_DIR/service_b.pem" \
  -days 825 -extensions v3_req -extfile "$CERT_DIR/service_b.cnf"

# Clean up
rm -f "$CERT_DIR"/*.csr "$CERT_DIR"/*.cnf "$CERT_DIR"/*.srl

echo "Certificates written to $CERT_DIR"
