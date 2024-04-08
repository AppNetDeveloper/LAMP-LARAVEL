#!/bin/sh

# Detener y deshabilitar servicios
sudo systemctl stop apache2
sudo systemctl stop nginx
sudo systemctl stop php8.3-fpm
sudo systemctl stop mariadb
sudo systemctl stop mysql
sudo systemctl stop redis-server
sudo systemctl stop jenkins
sudo systemctl stop webmin

sudo systemctl disable apache2
sudo systemctl disable nginx
sudo systemctl disable php8.3-fpm
sudo systemctl disable mariadb
sudo systemctl disable mysql
sudo systemctl disable redis-server
sudo systemctl disable jenkins
sudo systemctl disable webmin

sudo apt-get -y remove --purge nginx nginx-full nginx-common

sudo apt-get -y remove --purge mariadb-*
sudo apt-get -y remove --purge apache2 apache*
sudo apt-get -y remove --purge php8.3-fpm
sudo apt-get -y remove --purge php*
sudo apt-get -y remove --purge mariadb-server mariadb*

sudo apt-get -y remove --purge mysql mysql*
sudo apt-get -y remove --purge redis-server redis*
sudo apt-get -y remove --purge jenkins jekins*
sudo apt-get -y remove --purge  webmin webmin*

sudo apt-get -y remove --purge mariadb-*




# Limpiar directorios
sudo rm -rf /var/www/html
sudo rm -rf /etc/apache2
sudo rm -rf /etc/nginx
sudo rm -rf /etc/php
sudo rm -rf /etc/mysql
sudo rm -rf /var/lib/mysql
sudo rm -rf /etc/mysql/
sudo rm -rf /etc/redis
sudo rm -rf /var/lib/redis
sudo rm -rf /etc/jenkins
sudo rm -rf /etc/webmin
sudo rm -rf /etc/mysql /var/lib/mysql
sudo rm -rf /etc/mysql/mysql.sock
sudo rm -rf /var/lib/mysql

sudo delgroup mysql



# Eliminar repositorios
sudo rm -rf /etc/apt/sources.list.d/php.list
sudo rm -rf /etc/apt/sources.list.d/mssql-release.list
sudo rm -rf /etc/apt/sources.list.d/webmin.list

sudo apt -y autoremove

sudo apt -y update
