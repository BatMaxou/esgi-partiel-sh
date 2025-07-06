#!/bin/bash

set -e

ARCHIVE_DIR="./archives"
DOLIBARR_ARCHIVE="dolibarr-21.0.1.tgz"

WEB_DIR="/var/www"
DOLIBARR_DIR="$WEB_DIR/dolibarr"

DOLIBARR_APACHE_CONF_DIR="/etc/apache2/sites-available"
DOLIBARR_APACHE_CONF_FILE="$DOLIBARR_APACHE_CONF_DIR/002-dolibarr.conf"

SERVER_NAME="dolibarr"
DOCUMENT_ROOT=$DOLIBARR_DIR/public

DB_NAME="dolibarr"
DB_USER="dolibarr"
DB_PASSWORD="dolibarr"
MYSQL_ROOT_USER="root"
MYSQL_ROOT_PASSWORD="root"

# Get Dolibarr archive
mv $ARCHIVE_DIR/$DOLIBARR_ARCHIVE $WEB_DIR
cd $WEB_DIR
tar -xzf $WEB_DIR/$DOLIBARR_ARCHIVE
mv dolibarr-21.0.1 dolibarr
chown -R www-data:www-data $DOLIBARR_DIR

# Database
mysql -u root -p$MYSQL_ROOT_PASSWORD <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

# Apache
cat > $DOLIBARR_APACHE_CONF_FILE <<EOF
<VirtualHost *:80>
        ServerName $SERVER_NAME
        DocumentRoot $DOLIBARR_DIR
        Redirect / https://$SERVER_NAME/
</VirtualHost>
EOF

a2ensite 002-dolibarr.conf
sleep 2
systemctl reload apache2

echo ""
echo "============================================================"
echo "                 INSTALLATION DOLIBARR TERMINÉE"
echo "============================================================"
echo ""
