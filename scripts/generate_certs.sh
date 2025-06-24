#!/usr/bin/env bash
set -euo pipefail

CERT_DIR="$(dirname "$0")/../certs"
mkdir -p "$CERT_DIR"
cd "$CERT_DIR"

# Generate CA
openssl genrsa -out ca-key.pem 4096
openssl req -new -x509 -days 3650 -key ca-key.pem -subj "/CN=Demo CA" -out ca.pem

create_cert() {
  local name=$1
  cat > openssl.cnf <<CONFIG
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = req_ext

[ dn ]
CN = $name

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $name
DNS.2 = localhost
CONFIG

  openssl genrsa -out ${name}-key.pem 4096
  openssl req -new -key ${name}-key.pem -out ${name}.csr -config openssl.cnf
  openssl x509 -req -days 365 -in ${name}.csr -CA ca.pem -CAkey ca-key.pem \
    -CAcreateserial -out ${name}.pem -extensions req_ext -extfile openssl.cnf
  rm -f ${name}.csr openssl.cnf
}

create_cert consul-server
create_cert service_a
create_cert service_b

echo "Certificates generated in $CERT_DIR"
