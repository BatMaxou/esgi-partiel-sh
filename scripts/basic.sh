#!/bin/bash

set -e

USER=$1
PASSWORD=$2
APACHE_PAGE_CONF="/etc/apache2/sites-available/000-default.conf"
HTPASSWD_FILE="/etc/apache2/.htpasswd"

htpasswd -bc $HTPASSWD_FILE $USER $PASSWORD 

cat > $APACHE_PAGE_CONF <<EOF
<VirtualHost *:80>
    DocumentRoot /var/www/html

    <Directory "/var/www/html">
        AuthType Basic
        AuthName "basic_partiel"
        AuthUserFile $HTPASSWD_FILE
        <RequireAll>
            Require all granted
            Require valid-user
        </RequireAll>
    </Directory>
</VirtualHost>
EOF

systemctl reload apache2

echo ""
echo "============================================================"
echo "                 BASIC AUTH MIS EN PLACE"
echo "============================================================"
echo ""
