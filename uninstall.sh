#!/bin/sh
systemctl daemon-reload
sudo dpkg --configure -a
systemctl daemon-reload
# y eliminarlos del sistema

cd /root/csf
sudo /.uninstall.sh
sudo rm -rf /root/csf

# 1. Detener servicios web
sudo systemctl stop apache2
sudo systemctl stop nginx
sudo systemctl stop mariadb

# 2. Desinstalar Nginx con autoremove
sudo apt-get -y purge --auto-remove nginx nginx-common

# 3. Desinstalar Apache con autoremove
sudo apt-get -y purge --auto-remove apache2 apache2-utils apache2-data libapache2-mod-php*

# 4. Desinstalar MariaDB con autoremove
sudo apt-get -y purge --auto-remove mariadb-server mariadb-client

# 5. Desinstalar PHP con autoremove
sudo apt-get -y purge --auto-remove $(dpkg -l | grep ^ii | awk '{print $2}' | grep -E 'php|php-|^mysql|^libapache2-mod-|^phpMyAdmin' | xargs)

# 6. Eliminar directorios y archivos restantes (opcional)
# ¡Utiliza con precaución!
sudo rm -rf /etc/php /usr/local/lib/php /usr/share/php /var/lib/php /opt/lampp/lampp/htdocs/phpMyAdmin
sudo rm -rf /etc/nginx /var/lib/nginx
sudo rm -rf /etc/apache2 /var/lib/apache2
sudo rm -rf /etc/mysql /var/lib/mysql

# Apache
sudo systemctl stop apache2
sudo systemctl disable apache2
sudo systemctl stop apache*
sudo systemctl disable apache*
sudo apt-get -y remove apache2
sudo apt-get -y remove apache*
sudo apt-get -y purge apache2
sudo apt-get -y purge apache*
# Nginx
sudo systemctl stop nginx
sudo systemctl disable nginx
sudo apt-get -y remove --purge nginx nginx-full nginx-common

# PHP
sudo systemctl stop php8.3-fpm
sudo systemctl stop php8.2-fpm
sudo systemctl stop php*
sudo systemctl disable php8.3-fpm
sudo systemctl disable php8.2-fpm
sudo systemctl disable php*
sudo apt-get -y purge $(dpkg -l | grep ^ii | awk '{print $2}' | grep -E 'php|php-|^mysql|^libapache2-mod-|^phpMyAdmin' | xargs)

sudo apt-get -y remove --purge php8.2-fpm
sudo apt-get -y remove --purge php8.3-fpm
sudo apt-get -y remove --purge php*
udo apt-get -y remove --purge php8.2-common
sudo apt-get -y remove --purge php8.3-common
sudo apt-get -y remove --purge php*
sudo apt-get -y remove php8.2-common --purge
sudo apt-get -y remove php8.3-common --purge
sudo apt-get -y remove php8.3-common --purge

# MariaDB
sudo systemctl stop mariadb
sudo systemctl disable mariadb
sudo apt remove -y mariadb-server
sudo apt-get -y remove --purge mariadb-*

# MySQL
sudo systemctl stop mysql
sudo systemctl disable mysql
sudo apt-get -y remove --purge mysql-\*
sudo apt-get -y remove --purge mysql
sudo apt-get -y remove --purge mysql*
# Redis
sudo systemctl stop redis-server
sudo systemctl disable redis-server
sudo apt-get -y remove --purge redis-server
sudo apt-get -y remove --purge redis*

# Jenkins
sudo systemctl stop jenkins
sudo systemctl disable jenkins
sudo apt-get -y remove --purge jenkins
sudo apt-get -y remove --purge jekins*

# Webmin
sudo systemctl stop webmin
sudo systemctl disable webmin
sudo apt-get -y remove --purge webmin
sudo apt-get -y remove --purge webmin*

# ftp
sudo systemctl stop proftpd
sudo systemctl disable proftpd
sudo apt-get -y remove --purge proftpd*
sudo apt-get -y remove --purge proftpd

# Eliminar directorios de configuración y datos
sudo rm -rf /var/lib/mysql # Datos de MariaDB y MySQL
sudo rm -rf /etc/mysql     # Configuración de MariaDB y MySQL
sudo rm -rf /var/www/phpmyadmin
sudo rm -rf /etc/mysqlconfd                 # Configuración de conf.d de MySQL
sudo rm -rf /etc/apparmor.d/usr.sbin.mysqld # Configuración de AppArmor de MySQL
sudo rm -rf /etc/proftpd

# Vacía el archivo de registro de journalctl
sudo journalctl --vacuum-size=100M

# Limpiar directorios
sudo rm -rf /var/www/html  # Sitios web de Apache
sudo rm -rf /etc/apache2   # Configuración de Apache
sudo rm -rf /etc/nginx     # Configuración de Nginx
sudo rm -rf /etc/php       # Configuración de PHP
sudo rm -rf /etc/mysql     # Configuración de MySQL/MariaDB
sudo rm -rf /var/lib/mysql # Datos de MySQL/MariaDB
sudo rm -rf /etc/mysql/    # Configuración de MySQL/MariaDB
sudo rm -rf /etc/redis     # Configuración de Redis
sudo rm -rf /var/lib/redis # Datos de Redis
sudo rm -rf /etc/jenkins   # Configuración de Jenkins
sudo rm -rf /etc/webmin    # Configuración de Webmin
sudo rm -rf /etc/proftpd
sudo rm -rf /var/www/phpmyadmin
sudo rm -rf /var/www/phpMyAdmin*
# Eliminar grupo de MySQL
sudo delgroup mysql

# Eliminar repositorios
sudo rm -rf /etc/apt/sources.list.d/php.list           # Repositorio de PHP
sudo rm -rf /etc/apt/sources.list.d/mssql-release.list # Repositorio de SQL Server
sudo rm -rf /etc/apt/sources.list.d/webmin.list        # Repositorio de Webmin
sudo rm -rf /etc/apt/sources.list.d/*nginx*            # Repositorio de nginx
sudo rm -rf /etc/apt/sources.list.d/nginx*             # Repositorio de nginx

# Crear una copia de seguridad del archivo sources.list
cp /etc/apt/sources.list /etc/apt/sources.list.bak

# Eliminar líneas duplicadas
sed -i 'd/^\s*\#/g' /etc/apt/sources.list # Eliminar líneas de comentario
sed -i 'd/\s*$/g' /etc/apt/sources.list   # Eliminar líneas vacías
sort /etc/apt/sources.list | uniq -d >/tmp/sources.list.uniq

# Reemplazar el archivo sources.list con la versión depurada
mv /tmp/sources.list.uniq /etc/apt/sources.list

# Actualizar la caché de paquetes

sudo apt-get -y update
sudo apt-get -y upgrade # Uncomment this line to install the newest versions of all packages currently installed
# sudo apt-get -y dist-upgrade  # Uncomment this line to, in addition to 'upgrade', handles changing dependencies with new versions of packages
sudo apt-get -y autoremove # Uncomment this line to remove packages that are now no longer needed
systemctl daemon-reload
sudo apt autoremove
#sudo apt -y update # Actualiza la lista de paquetes

sudo dpkg --configure -a
