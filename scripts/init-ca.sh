#!/bin/bash

set -e

SSL_DIR="/etc/ssl/partiel/ca"

# Generate cert
mkdir -p $SSL_DIR
cd $SSL_DIR
openssl genpkey -algorithm RSA -out ca.key -pkeyopt rsa_keygen_bits:4096
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.pem -subj "/CN=PARTIEL-CA"
openssl x509 -in ca.pem -inform PEM -out ca.crt

echo ""
echo "============================================================"
echo "                      CA GÉNÉRÉE"
echo "============================================================"
echo ""
