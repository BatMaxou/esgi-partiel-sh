#!/bin/bash

set -e

SOLUTION=$1
SSL_DIR="/etc/ssl/partiel"
APACHE_SSL_CONF="/etc/apache2/sites-available/default-ssl.conf"

# Install Apache SSL package
a2enmod ssl

# Generate cert
mkdir -p $SSL_DIR
cd $SSL_DIR
openssl genpkey -algorithm RSA -out $SOLUTION.key -pkeyopt rsa_keygen_bits:4096
openssl req -x509 -new -nodes -key $SOLUTION.key -sha256 -days 90 -out $SOLUTION.pem -subj "/CN=$SOLUTION-CA"
openssl x509 -in $SOLUTION.pem -inform PEM -out $SOLUTION.crt

# Activate SSL for solution
cat $APACHE_SSL_CONF >> /etc/apache2/sites-available/002-$SOLUTION.conf

sed "s|SSLCertificateFile      /etc/ssl/certs/ssl-cert-snakeoil.pem|SSLCertificateFile $SSL_DIR/$SOLUTION.crt|" 
sed "s|SSLCertificateKeyFile   /etc/ssl/private/ssl-cert-snakeoil.key|SSLCertificateKeyFile $SSL_DIR/$SOLUTION.key|"

systemctl reload apache2
