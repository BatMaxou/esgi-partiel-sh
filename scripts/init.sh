# PHP
apt install \
    php-common \
    php-cli \
    libapache2-mod-php \
    php-bz2 \
    php-intl \
    php-gd \
    php-mbstring \
    php-mysql \
    php-xml \
    php-zip \
    php-curl \
    -y

# Apache
apt install apache2 -y
a2enmod ssl

# MySQL
apt install mariadb-server -y
mysql_secure_installation

