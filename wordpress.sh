#!/bin/bash
clear

###RECUERDA EJECUTARLO COMO ROOT###

###VARIABLES### Puedes cambiar los valores para que se adapte a tu entorno
#Usuario y contraseña de root para MySQL
MyUSER='root'
MyPASS='root'
#Nombre del directorio de Wordpress
WPNAME='castelar'
#Ruta del directorio que sirve el servidor web
WPDIR='/var/www/html'
#Nombre de la base de datos de Wordpress
DBNAME='wordpress'
#Usuario y contraseña con privilegios sobre la base de datos de Wordpress
DBUSER='user'
DBPASS='user'

#Variable para introducir " ' " en el fichero wp-config.php
AP="'"


#Actualizar paquetes y descargar los que necesitamos
apt-get update
apt-get install apache2 -y
echo "mysql-server mysql-server/root_password" $MyPASS | debconf-set-selections
echo "mysql-server mysql-server/root_password_again" $MyPASS | debconf-set-selections
apt-get install mysql-server -y
apt-get install php -y
apt-get install php-mysql -y

#Descargar Wordpress
wget http://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz
rm latest.tar.gz

#Cambiar el propietario y grupo de Wordpress
chown -R www-data:www-data wordpress

#Crear base de datos y usuario
mysql -u $MyUSER -p$MyPASS -se "create database $DBNAME;" 2>/dev/null
mysql -u $MyUSER -p$MyPASS -se "GRANT ALL PRIVILEGES ON $DBNAME.* to $AP$DBUSER$AP@'%' identified by $AP$DBPASS$AP;" 2>/dev/null
mysql -u $MyUSER -p$MyPASS -se "flush privileges;" 2>/dev/null

#Crear el fichero 'wp-config.php'
echo "<?php" > wordpress/wp-config.php
echo "define('DB_NAME', "$AP$DBNAME$AP");" >> wordpress/wp-config.php
echo "define('DB_USER', "$AP$DBUSER$AP");" >> wordpress/wp-config.php
echo "define('DB_PASSWORD', "$AP$DBPASS$AP");" >> wordpress/wp-config.php
echo "define('DB_HOST', 'localhost');" >> wordpress/wp-config.php
echo "define('DB_CHARSET', 'utf8');" >> wordpress/wp-config.php
echo "define('DB_COLLATE', '');" >> wordpress/wp-config.php
echo "define('AUTH_KEY',         'put your unique phrase here');" >> wordpress/wp-config.php
echo "define('SECURE_AUTH_KEY',  'put your unique phrase here');" >> wordpress/wp-config.php
echo "define('LOGGED_IN_KEY',    'put your unique phrase here');" >> wordpress/wp-config.php
echo "define('NONCE_KEY',        'put your unique phrase here');" >> wordpress/wp-config.php
echo "define('AUTH_SALT',        'put your unique phrase here');" >> wordpress/wp-config.php
echo "define('SECURE_AUTH_SALT', 'put your unique phrase here');" >> wordpress/wp-config.php
echo "define('LOGGED_IN_SALT',   'put your unique phrase here');" >> wordpress/wp-config.php
echo "define('NONCE_SALT',       'put your unique phrase here');" >> wordpress/wp-config.php
echo "$""table_prefix = 'wp_';" >> wordpress/wp-config.php
echo "define('WP_DEBUG', false);" >> wordpress/wp-config.php
echo "if ( !defined('ABSPATH') )" >> wordpress/wp-config.php
echo "  define('ABSPATH', dirname(__FILE__) . '/');" >> wordpress/wp-config.php
echo "require_once(ABSPATH . 'wp-settings.php');" >> wordpress/wp-config.php

#Mover la carpeta al directorio que sirve apache
mv wordpress $WPDIR/$WPNAME

#Crear un host virtual para Wordpress
cd /etc/apache2/sites-available
cp 000-default.conf $WPNAME.conf
a2ensite $WPNAME.conf
a2dissite 000-default.conf
systemctl restart apache2
