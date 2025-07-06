#!/bin/bash

set -e

ARCHIVE_DIR="./archives"
GLPI_ARCHIVE="glpi-10.0.18.tgz"

WEB_DIR="/var/www"
GLPI_DIR="$WEB_DIR/glpi"

GLPI_APACHE_CONF_DIR="/etc/apache2/sites-available"
GLPI_APACHE_CONF_FILE="$GLPI_APACHE_CONF_DIR/002-glpi.conf"

SERVER_NAME="glpi"
DOCUMENT_ROOT=$GLPI_DIR/public

DB_NAME="glpi"
DB_USER="glpi"
DB_PASSWORD="glpi"
MYSQL_ROOT_USER="root"
MYSQL_ROOT_PASSWORD="root"

# PHP extensions (optionnal ? may be deleted i guess)
apt install \
    php-bz2 \
    php-intl \
    php-gd \
    php-mbstring \
    php-mysql \
    php-xml \
    php-zip \
    php-curl \
    -y

# Get GLPI archive
mv $ARCHIVE_DIR/$GLPI_ARCHIVE $WEB_DIR
cd $WEB_DIR
tar -xzf $WEB_DIR/$GLPI_ARCHIVE
chown -R www-data:www-data $GLPI_DIR

# Database
mysql -u root -p$MYSQL_ROOT_PASSWORD <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

# Apache
cat > $GLPI_APACHE_CONF_FILE <<EOF
<VirtualHost *:80>
        ServerName $SERVER_NAME
        DocumentRoot $GLPI_DIR
        Redirect / https://$SERVER_NAME/
</VirtualHost>
EOF

a2ensite 002-glpi.conf
sleep 2
systemctl reload apache2

# Auto finish install

# GET clean base to test importing it

# cd $GLPI_DIR
# cat > config/config_db.php <<EOF
# <?php
# class DB extends DBmysql {
#    public \$dbhost = 'localhost';
#    public \$dbuser = 'glpi';
#    public \$dbpassword = 'glpi';
#    public \$dbdefault = 'glpi';
#    public \$use_utf8mb4 = true;
#    public \$allow_myisam = false;
#    public \$allow_datetime = false;
#    public \$allow_signed_keys = false;
# }
# EOF
# chown -R www-data:www-data config/config_db.php
# chmod 755 config/config_db.php

echo ""
echo "============================================================"
echo "                 INSTALLATION GLPI TERMINÉE"
echo "============================================================"
echo ""
