#!/bin/sh
sudo dpkg --configure -a
# Detener y deshabilitar servicios
# y eliminarlos del sistema

# Apache
sudo systemctl stop apache2
sudo systemctl disable apache2
sudo apt-get -y remove --purge apache2 apache*

# Nginx
sudo systemctl stop nginx
sudo systemctl disable nginx
sudo apt-get -y remove --purge nginx nginx-full nginx-common

# PHP
sudo systemctl stop php8.3-fpm
sudo systemctl stop php8.2-fpm
sudo systemctl disable php8.3-fpm
sudo systemctl disable php8.2-fpm
sudo apt-get -y remove --purge php8.2-fpm
sudo apt-get -y remove --purge php8.3-fpm
sudo apt-get -y remove --purge php*

# MariaDB
sudo systemctl stop mariadb
sudo systemctl disable mariadb
sudo apt remove -y mariadb-server
sudo apt-get -y remove --purge mariadb-*

# MySQL
sudo systemctl stop mysql
sudo systemctl disable mysql
sudo apt-get -y remove --purge mysql-\*
sudo apt-get -y remove --purge mysql mysql*

# Redis
sudo systemctl stop redis-server
sudo systemctl disable redis-server
sudo apt-get -y remove --purge redis-server redis*

# Jenkins
sudo systemctl stop jenkins
sudo systemctl disable jenkins
sudo apt-get -y remove --purge jenkins jekins*

# Webmin
sudo systemctl stop webmin
sudo systemctl disable webmin
sudo apt-get -y remove --purge webmin webmin*


# Eliminar directorios de configuración y datos
sudo rm -rf /var/lib/mysql # Datos de MariaDB y MySQL
sudo rm -rf /etc/mysql # Configuración de MariaDB y MySQL
sudo rm -rf /var/www/phpmyadmin
sudo rm -rf /etc/mysqlconfd # Configuración de conf.d de MySQL
sudo rm -f /etc/apparmor.d/usr.sbin.mysqld # Configuración de AppArmor de MySQL

# Vacía el archivo de registro de journalctl
sudo journalctl --vacuum-size=100M

# Limpiar directorios
sudo rm -rf /var/www/html # Sitios web de Apache
sudo rm -rf /etc/apache2 # Configuración de Apache
sudo rm -rf /etc/nginx # Configuración de Nginx
sudo rm -rf /etc/php # Configuración de PHP
sudo rm -rf /etc/mysql # Configuración de MySQL/MariaDB
sudo rm -rf /var/lib/mysql # Datos de MySQL/MariaDB
sudo rm -rf /etc/mysql/ # Configuración de MySQL/MariaDB
sudo rm -rf /etc/redis # Configuración de Redis
sudo rm -rf /var/lib/redis # Datos de Redis
sudo rm -rf /etc/jenkins # Configuración de Jenkins
sudo rm -rf /etc/webmin # Configuración de Webmin

# Eliminar grupo de MySQL
sudo delgroup mysql



# Eliminar repositorios
sudo rm -rf /etc/apt/sources.list.d/php.list # Repositorio de PHP
sudo rm -rf /etc/apt/sources.list.d/mssql-release.list # Repositorio de SQL Server
sudo rm -rf /etc/apt/sources.list.d/webmin.list # Repositorio de Webmin

sudo apt -y autoremove # Elimina paquetes no utilizados

sudo apt -y update # Actualiza la lista de paquetes

sudo dpkg --configure -a
