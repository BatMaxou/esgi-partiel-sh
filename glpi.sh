#!/bin/bash

set -e

GLPI_ARCHIVE="glpi-10.0.18.tgz"

WEB_DIR="/var/www"
GLPI_DIR="$WEB_DIR/glpi"

GLPI_APACHE_CONF_DIR="/etc/apache2/sites-available"
GLPI_APACHE_CONF_FILE="$GLPI_APACHE_CONF_DIR/002-glpi.conf"

DB_NAME="glpi"
DB_USER="glpi"
DB_PASSWORD="glpi"
MYSQL_ROOT_USER="root"
MYSQL_ROOT_PASSWORD="root"

# PHP extensions (optionnal ? may be deleted i guess)
apt install php-{gd,zip,curl,xml,mysql,mbstring,bcmath,intl,dom,fileinfo,simplexml,xmlreader,xmlwriter,bz2,phar,ldap,opcache} -y

# Get GLPI archive
mkdir -p $GLPI_DIR
mv $GLPI_ARCHIVE $WEB_DIR
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
    ServerName glpi
    DocumentRoot $GLPI_DIR
</VirtualHost>
EOF>>

a2ensite 002-glpi.conf
systemctl reload apache2

# Install
cd $GLPI_DIR

php bin/console glpi:database:install \
    --no-interaction \
    --db-host=localhost \
    --db-name=$DB_NAME \
    --db-user=$DB_USER \
    --db-password=$DB_PASSWORD

rm -rf $GLPI_DIR/install

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
echo "   URL par nom serveur:   http://glpi/glpi"
echo ""
echo "🔧 CONFIGURATION APACHE:"
echo "   Fichier de config:     $GLPI_APACHE_CONF_FILE"
echo "   Site activé:           002-glpi.conf"
echo "   DocumentRoot:          $GLPI_DIR"
echo "   ServerName:            glpi"
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
