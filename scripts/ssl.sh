#!/bin/bash

set -e

SOLUTION=$1
SSL_DIR="/etc/ssl/partiel"
CA_DIR="$SSL_DIR/ca"
APACHE_SSL_CONF="/etc/apache2/sites-available/default-ssl.conf"
SOLUTION_CONF="/etc/apache2/sites-available/002-$SOLUTION.conf"

# Install Apache SSL package
a2enmod ssl

# Generate cert
mkdir -p $SSL_DIR
cd $SSL_DIR
openssl genpkey -algorithm RSA -out $SOLUTION.key -pkeyopt rsa_keygen_bits:4096
openssl req -x509 -new -nodes -key $SOLUTION.key -sha256 -days 90 -out $SOLUTION.pem -subj "/CN=$SOLUTION-CA"
openssl x509 -in $SOLUTION.pem -inform PEM -out $SOLUTION.crt
# openssl x509 -req -CA $CA_DIR/ca.crt -CAkey $CA_DIR/ca.key -in $SOLUTION.pem -out $SOLUTION.crt

# Activate SSL for solution
cat $APACHE_SSL_CONF >> $SOLUTION_CONF
sed \
    -e "s|ServerName webmaster|ServerName $SOLUTION|" \
    -e "s|DocumentRoot /var/www/html|DocumentRoot /var/www/$SOLUTION|" \
    -e "s|SSLCertificateFile      /etc/ssl/certs/ssl-cert-snakeoil.pem|SSLCertificateFile $SSL_DIR/$SOLUTION.pem|" \
    -e "s|SSLCertificateKeyFile   /etc/ssl/private/ssl-cert-snakeoil.key|SSLCertificateKeyFile $SSL_DIR/$SOLUTION.key|" \
    -e "s|#SSLCACertificateFile /etc/apache2/ssl.crt/ca-bundle.crt|SSLCACertificateFile $CA_DIR/ca.crt|" \
    -e "s|#SSLVerifyClient|SSLVerifyClient|" \
    -e "s|#SSLVerifyDepth 10|SSLVerifyDepth 2|" \
    -i $SOLUTION_CONF

systemctl reload apache2

echo ""
echo "============================================================"
echo "              SSL MIS EN PLACE POUR $SOLUTION"
echo "============================================================"
echo ""
