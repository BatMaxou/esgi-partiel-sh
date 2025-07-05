#!/bin/bash

set -e

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
mv $GLPI_ARCHIVE $WEB_DIR
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

# Fancy stuff
echo ""
echo "============================================================"
echo "                 INSTALLATION GLPI TERMINÉE"
echo "============================================================"
echo ""
echo "📦 INFORMATIONS GÉNÉRALES:"
echo "   Version GLPI:          10.0.18"
echo "   Répertoire installation: $GLPI_DIR"
echo "   Archive source:        $GLPI_ARCHIVE"
echo "   Propriétaire fichiers: www-data:www-data"
echo ""
echo "🌐 ACCÈS WEB:"
echo "   URL par nom serveur:   http://glpi"
echo ""
echo "🔧 CONFIGURATION APACHE:"
echo "   Fichier de config:     $GLPI_APACHE_CONF_FILE"
echo "   Site activé:           002-glpi.conf"
echo "   DocumentRoot:          $GLPI_DIR"
echo "   ServerName:            $SERVER_NAME"
echo ""
echo "🗄️  BASE DE DONNÉES:"
echo "   Nom de la base:        $DB_NAME"
echo "   Utilisateur GLPI:      $DB_USER"
echo "   Mot de passe:          $DB_PASSWORD"
echo ""
echo "🚀 PROCHAINES ÉTAPES:"
echo "   1. Connectez-vous avec le compte 'glpi'"
echo "   2. Accédez à Configuration > Générale"
echo "   3. Configurez votre organisation"
echo "   4. Créez vos utilisateurs personnalisés"
echo "   5. Supprimez les comptes par défaut non utilisés"
echo ""
echo "============================================================"
echo "        Installation terminée avec succès ! 🎉"
echo "============================================================"
