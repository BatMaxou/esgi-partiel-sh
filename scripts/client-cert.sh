#!/bin/bash

set -e

CLIENT=$1

SSL_DIR="/etc/ssl/partiel"
CA_DIR="$SSL_DIR/ca"
CLIENT_DIR="$SSL_DIR/client"

# Generate client cert
mkdir -p $CLIENT_DIR
cd $CLIENT_DIR
openssl genpkey -algorithm RSA -out $CLIENT.key -pkeyopt rsa_keygen_bits:4096
openssl req -new -key $CLIENT.key -out $CLIENT.csr -subj "/CN=$CLIENT"
openssl x509 -req -CA $CA_DIR/ca.crt -CAkey $CA_DIR/ca.key -in $CLIENT.csr -out $CLIENT.crt
openssl pkcs12 -export -in $CLIENT.crt -inkey $CLIENT.key -out $CLIENT.p12

chown maxime:maxime $CLIENT_DIR/$CLIENT.p12

echo ""
echo "============================================================"
echo "            CERTIFICAT CLIENT CRÉÉ POUR $CLIENT"
echo "Fichier .p12 à importer dans le navigateur : $CLIENT_DIR/$CLIENT.p12"
echo "============================================================"
echo ""
