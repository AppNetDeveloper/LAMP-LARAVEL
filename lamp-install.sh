#!/bin/bash
WEB_SERVER="$1"
DB="$2"
INSTALL="$3"
VPN="$4"
if [ "$WEB_SERVER" = "apache" ]; then
    echo "Instalando Apache..."
elif [ "$WEB_SERVER" = "nginx" ]; then
    echo "Instalando Nginx..."
else
    echo "Por favor especifica 'apache' o 'nginx' como argumento al ejecutar este script. Ejemplo: sh install.sh apache o sh install.sh nginx"
    exit 1
fi

if [ "$DB" = "none" ]; then
    echo "Sin MariaDB...."
elif [ "$DB" = "appnetd_cloud" ]; then
    echo "Instalar MariaDB y crear tabla appnetd_cloud!..."

else
    echo "Por favor especifica 'none' o 'appnetd_cloud' como argumento al ejecutar este script. Ejemplo: sh install.sh apache none o appnetd_cloud o sh install.sh nginx none o uma"
    exit 1
fi
	
if [ "$INSTALL" = "none" ]; then
    echo 'Sin Installar  '
elif [ "$INSTALL" != "" ]; then
    echo 'Installar appnetd_cloud'
else
    echo "Por favor especifica none o install en instalacion "
    exit 1
fi

if [ "$VPN" = "none" ]; then
    echo 'Sin VPN P2P Zerotier, Sin abrir Puertos '
elif [ "$VPN" != "" ]; then
    echo 'Installar VPN Zerotier'
else
    echo "Por favor especifica none o EL ID RED en instalacion "
    exit 1
fi

# Instalar sudo
apt -y install sudo

# Save existing php package list to packages.txt file
sudo dpkg -l | grep php | tee packages.txt

# Add Ondrej's repo source and signing key along with dependencies
sudo apt install apt-transport-https
sudo curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

sudo add-apt-repository ppa:ondrej/php # Press enter when prompted.

sudo apt update

# Install new PHP 8.3 packages
sudo apt install php8.3 php8.3-cli php8.3-{bz2,curl,mbstring,intl}

# Install FPM OR Apache module
sudo apt install php8.3-fpm
# OR
# sudo apt install libapache2-mod-php8.3

# On Apache: Enable PHP 8.3 FPM
sudo a2enconf php8.3-fpm
# When upgrading from an older PHP version:
sudo a2disconf php8.2-fpm
sudo a2disconf php8.1-fpm



## Remove old packages
sudo apt purge php8.2*
# Remove old packages
sudo apt purge php8.2*
sudo apt purge php8.1*
sudo apt purge php8.0*

# Instalar curl y wget
sudo apt install -y curl wget

# Actualizar e instalar los paquetes necesarios
sudo apt update && sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates gnupg2 software-properties-common

# Descargar la clave GPG para el repositorio de PHP
sudo wget -qO /etc/apt/trusted.gpg.d/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg

# Agregar la clave de Zend
curl -s https://repos.zend.com/zend.key | gpg --dearmor > /usr/share/keyrings/zend.gpg

# Añadir el repositorio de PHP a la lista de fuentes de paquetes
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list

# Descargar la clave GPG para el repositorio de PHP de nuevo (parece repetitivo, puede ser necesario sólo una vez)
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg

# Añadir el repositorio de PHP a la lista de fuentes de paquetes de nuevo (también parece repetitivo, puede ser necesario sólo una vez)
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

# Actualizar los paquetes
sudo apt update && sudo apt upgrade -y

# Instalar PHP y las extensiones necesarias
sudo apt install -y php8.3 php8.3-fpm php8.3-mysql php8.3-curl php8.3-gd php8.3-imagick php8.3-intl php8.3-mysql php8.3-mbstring php8.3-xml php8.3-mcrypt php8.3-zip php8.3-ldap libapache2-mod-php8.3 php8.3-sybase php8.3-opcache php8.3-pgsql php8.3-redis

# Instalar php8.3-sql
sudo apt install -y php8.3-sql 

sudo apt install -y php-opcache
sudo apt install -y php8.3-opcache
sudo apt install -y php8.3-curl
sudo apt install -y php-curl
sudo apt install -y php-zip
sudo apt install -y php8.3-zip
sudo apt-get -y install php-ssh2
sudo apt-get -y install php8.3-ssh2
sudo apt install php-xml -y
sudo systemctl restart php8.3-fpm 
sudo apt install php-curl -y
sudo apt install php-mbstring -y


# Solucionar problemas de php8.3 mysql sql
# Hay un error en la siguiente línea. Debe ser dividido en dos comandos separados
sudo apt install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt-get install php-pear
sudo pecl channel-update pecl.php.net

# Este parece ser incorrecto. En su lugar, puedes hacer referencia a /usr/bin/php8.3 (o el camino correcto a tu binario PHP).
#pear config-set php_bin "/usr/lib/cgi-bin/php8.3"
sudo pear config-set php_bin /usr/bin/php8.3

# Añadir la clave de Microsoft
sudo curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

# Añadir los repositorios de Microsoft
sudo curl https://packages.microsoft.com/config/debian/12/prod.list > /etc/apt/sources.list.d/mssql-release.list
sudo curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list
sudo curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list

# Instalar las herramientas de Microsoft SQL
sudo apt-get -y install msodbcsql17
sudo apt-get -y install mssql-tools
sudo apt-get -y install unixodbc-dev
sudo apt-get -y install php-dev

# Instalar las extensiones PHP para Microsoft SQL
sudo pecl install pdo_sqlsrv
sudo pecl install sqlsrv

# Habilitar las extensiones PHP para Microsoft SQL
echo "; priority=20\nextension=sqlsrv.so\n" > /etc/php/8.3/mods-available/sqlsrv.ini
echo "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/8.3/mods-available/pdo_sqlsrv.ini
sudo phpenmod -v 8.3 sqlsrv pdo_sqlsrv

sudo apt -y install gcc g++ make



curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
sudo apt install nodejs

wget https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh
bash install.sh
source ~/.bashrc
nvm list-remote 

nvm install v18
nvm install node
nvm use 18
nvm alias default 18


if [ "$WEB_SERVER" = "apache" ]; then
    echo "Instalando Apache..."
    # Aquí va el código para instalar Apache.
	sudo apt -y remove nginx
	sudo systemctl stop nginx
	sudo apt install -y apache2
	sudo a2enmod proxy_fcgi setenvif
	sudo a2enconf php8.3-fpm
	sudo a2disconf php8.1-fpm
	sudo a2dismod php8.1
	sudo a2dismod php8.3
	sudo systemctl enable php8.3-fpm
	sudo systemctl reload apache2
	sudo service apache2 restart
	sudo service php8.3-fpm restart
	
	# Define el nombre del archivo de configuración
	echo 'anadir nueva configuracion apache'
APACHE_CONFIG_FILE="/etc/apache2/sites-available/000-default.conf"
mv ${APACHE_CONFIG_FILE} ${APACHE_CONFIG_FILE}.back

# Escribe la configuración en el archivo
echo "<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/public

    <Directory /var/www/html/mi-sitio/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" | sudo tee ${APACHE_CONFIG_FILE}

# Reinicia el servidor Apache para que los cambios surtan efecto
sudo service apache2 restart

sudo chmod -R 777 /var/www/html
echo 'anadir apache web control'
sudo wget https://excellmedia.dl.sourceforge.net/project/apachegui/1.12-Linux-Solaris-Mac/ApacheGUI-1.12.0.tar.gz
sudo tar -xzvf ApacheGUI-1.12.0.tar.gz -C /usr/local/
cd /usr/local/ApacheGUI/bin
sudo ./run.sh
	
elif [ "$WEB_SERVER" = "nginx" ]; then
    echo "Instalando Nginx..."
    # Aquí va el código para instalar Nginx.
	sudo a2enmod proxy_fcgi setenvif
	sudo a2enconf php8.3-fpm
	sudo a2disconf php8.1-fpm
	sudo a2dismod php8.1
	sudo a2dismod php8.3
	sudo systemctl enable php8.3-fpm
	sudo systemctl reload apache2
	sudo service apache2 restart
	sudo service php8.3-fpm restart
	sudo systemctl stop apache2
	sudo service stop restart
	sudo apt -y purge apache2 apache2-utils
	sudo apt -y remove apache2 apache2-utils
	sudo apt -y autoremove apache2 apache2-utils

	sudo apt list nginx
	sudo apt -y install nginx
	
	sudo chmod 755 -R /var/www/html/
	sudo chown www-data:www-data -R /var/www/html/

	#backup conf
	echo 'hacemos una copia de nginx conf antes de poner la nueva'
	sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
	sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup


# Crear un nuevo archivo de configuración con todas las optimizacion de gzip para aumentar velocidad de carga
sudo bash -c 'cat > /etc/nginx/nginx.conf << EOL
user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 768;
        # multi_accept on;
}

http {
        sendfile on;
        tcp_nopush on;
        types_hash_max_size 2048;
        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        access_log /var/log/nginx/access.log;

        gzip on;

         gzip_vary on;
         gzip_proxied any;
         gzip_proxied expired no-cache no-store private auth;
         gzip_comp_level 9;
         gzip_buffers 16 8k;
         gzip_http_version 1.1;
         gzip_min_length 256;
         gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss application/atom+xml application/geo+json application/x-javascript application/json application/ld+json applica>
         gzip_disable "MSIE [1-6]\.";

        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;
}
EOL'
echo 'config con exito'

# Crear un nuevo archivo de configuración
echo 'Crear un nuevo archivo de configuración nginx MEJORADO'
sudo bash -c 'cat > /etc/nginx/sites-available/default << EOL
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html/public;

        index index.html index.htm index.nginx-debian.html index.php;

        server_name _;

        location / {
                try_files \$uri \$uri/ /index.php?\$query_string;
        }


        location ~ \\.php$ {
                include snippets/fastcgi-php.conf;
     
                fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        #       fastcgi_pass 127.0.0.1:9000;
        }
}
EOL'


echo 'config con exito'


# Reiniciar Nginx
sudo systemctl restart nginx
	
	# Nginx webGui, el panel de control para nginx sin tocar el root del servidor. Ademas se pueden crear varios vhost o proxys ilimitados
	curl -L -s https://raw.githubusercontent.com/0xJacky/nginx-ui/master/install.sh -o installgui.sh
	chmod +x installgui.sh
	./installgui.sh install

else
    echo "Por favor especifica 'apache' o 'nginx' como argumento al ejecutar este script. Ejemplo: sh install.sh apache o sh install.sh nginx"
    exit 1
fi

#Composer Install
sudo apt install -y curl php-cli php-mbstring git unzip
cd ~
curl -sS https://getcomposer.org/installer -o composer-setup.php
HASH=`curl -sS https://composer.github.io/installer.sig`
php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer

#NPM install
sudo apt install -y nodejs npm



# Añade las líneas al archivo www.conf
echo "pm = dynamic" | sudo tee -a /etc/php/8.3/fpm/pool.d/www.conf
echo "pm.max_children = 250" | sudo tee -a /etc/php/8.3/fpm/pool.d/www.conf
echo "pm.start_servers = 10" | sudo tee -a /etc/php/8.3/fpm/pool.d/www.conf
echo "pm.min_spare_servers = 5" | sudo tee -a /etc/php/8.3/fpm/pool.d/www.conf
echo "pm.max_spare_servers = 20" | sudo tee -a /etc/php/8.3/fpm/pool.d/www.conf

# Añade las líneas al archivo php.ini
echo "memory_limit=4096M" | sudo tee -a /etc/php/8.3/cli/php.ini
echo "date.timezone=Europe/Madrid" | sudo tee -a /etc/php/8.3/cli/php.ini
echo "post_max_size=20000M" | sudo tee -a /etc/php/8.3/cli/php.ini
echo "upload_max_filesize=20000M" | sudo tee -a /etc/php/8.3/cli/php.ini
echo "max_execution_time=180000" | sudo tee -a /etc/php/8.3/cli/php.ini
echo "max_input_time=12000" | sudo tee -a /etc/php/8.3/cli/php.ini


#Esta nueva version anade estos dos parametros directamente en la instalcion por ser repo de microsoft
#echo "extension=sqlsrv" | sudo tee -a /etc/php/8.3/cli/php.ini
#echo "extension=pdo_sqlsrv" | sudo tee -a /etc/php/8.3/cli/php.ini

#anadir zend para mejor velocidad en web server
echo "[opcache]" | sudo tee -a /etc/php/8.3/cli/php.ini
echo "zend_extension=opcache.so" | sudo tee -a /etc/php/8.3/cli/php.ini
echo "opcache.enable=1" | sudo tee -a /etc/php/8.3/cli/php.ini
echo "opcache.memory_consumption=128" | sudo tee -a /etc/php/8.3/cli/php.ini
echo "opcache.interned_strings_buffer=8" | sudo tee -a /etc/php/8.3/cli/php.ini
echo "opcache.max_accelerated_files=4000" | sudo tee -a /etc/php/8.3/cli/php.ini
echo "opcache.revalidate_freq=60" | sudo tee -a /etc/php/8.3/cli/php.ini
echo "opcache.fast_shutdown=1" | sudo tee -a /etc/php/8.3/cli/php.ini

# Reinicia el servicio php8.3-fpm y apache
sudo service php8.3-fpm restart
sudo service apache2 restart
sudo systemctl restart nginx


echo 'Pasamos a Mariadb'
if [ "$DB" = "none" ]; then
    echo "Sin MariaDB...."
elif [ "$DB" = "appnetd_cloud" ]; then
    echo "Instalar MariaDB y crear tabla appnetd_cloud"
	# Actualiza los paquetes del sistema
	sudo apt update

	# Instala MariaDB
	sudo apt install -y mariadb-server

# Ejecuta el script de seguridad de MySQL
sudo mysql_secure_installation <<EOF

y
Cvlss2101281613
Cvlss2101281613
y
y
y
y
EOF
echo " MAriadb Instalado, paro a la config"
	# Inicia el servidor MariaDB
	sudo systemctl start mariadb
	sudo systemctl enable mariadb

	# Crea la base de datos "appnetd_cloud"
	echo "CREATE DATABASE appnetd_cloud;" | mysql -u root -p'Cvlss2101281613'
	# Define tu contraseña
	ROOT_PASSWORD="Cvlss2101281613"
echo "cambiar contraseña root"
	# Cambia la contraseña de root
	sudo mysql -u root <<-EOF
	ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_PASSWORD';
	FLUSH PRIVILEGES;
	EOF

	
	DB_NAME="appnetd_cloud"
	DB_USER="root"
echo "crear el usuario dar permisos"

	# Iniciar sesión en MySQL/MariaDB como root
	mysql -u root -p$ROOT_PASSWORD <<EOF
-- Crear el usuario y otorgar los permisos
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%' IDENTIFIED BY '$ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF


# # Iniciar sesión en MySQL/MariaDB como root y ejecutar el comando SQL
# mysql -u root -p$ROOT_PASSWORD -e "CREATE DATABASE $DB_NAME; GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost'; FLUSH PRIVILEGES;"
		
	
	# Hacemos una copia de seguridad del archivo original
	sudo cp /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf.backup

RAM=$(awk '/MemTotal/ {printf("%.0f\n", $2/1024/1024*0.8)}' /proc/meminfo)

# Añadimos las nuevas configuraciones al archivo
sudo bash -c "cat >> /etc/mysql/mariadb.conf.d/50-server.cnf" <<EOF

bind-address = 0.0.0.0
[mysqld]
# Configuraciones de rendimiento
innodb_buffer_pool_size = '${RAM}G'  # Aumentado para usar más RAM siendo el maximo de 80% del servidor CALCULO AUTOMATICO
innodb_log_file_size = 1G  
max_connections = 200  # Aumentado para permitir más conexiones
query_cache_size = 256M  # Aumentado para cachear más consultas
join_buffer_size = 256M  # Aumentado para consultas JOIN más grandes
tmp_table_size = 1024M  # Aumentado para tablas temporales más grandes
max_heap_table_size = 1024M  # Aumentado para tablas en memoria más grandes

innodb_io_capacity = 5000  # Aumentado para permitir más I/O por segundo
innodb_io_capacity_max = 10000  # Aumentado para permitir más I/O máximo por segundo
innodb_read_io_threads = 64  
innodb_write_io_threads = 64  
innodb_flush_log_at_trx_commit = 1  # Cambiado a 1 para mayor integridad de los datos
innodb_flush_method = O_DIRECT  
innodb_log_buffer_size = 128M  # Aumentado para más buffer de registro
thread_cache_size = 100  # Aumentado para cachear más hilos

# Configuraciones de logs
expire_logs_days = 10
EOF


	# Reiniciamos el servicio para que los cambios tengan efecto
	sudo systemctl restart mariadb

else
    echo "Por favor especifica 'none' o 'appnetd_cloud' como argumento al ejecutar este script. Ejemplo: sh install.sh apache none o uma o sh install.sh nginx none o uma"
    exit 1
fi


# Agrega el repositorio de Webmin
echo 'install webmin'
cd /tmp

echo "deb http://download.webmin.com/download/repository sarge contrib" | sudo tee /etc/apt/sources.list.d/webmin.list

# Agrega la llave del repositorio
wget -q http://www.webmin.com/jcameron-key.asc -O- | sudo apt-key add -

# Actualiza los paquetes del sistema
sudo apt update

# Instala Webmin
sudo apt install -y webmin

# Asegúrate de que Webmin se inicie al arrancar el sistema
sudo systemctl enable webmin

sudo systemctl start webmin

#redis
sudo apt -y install redis-server
sudo systemctl enable --now redis-server.service


# Install Jenkins
echo 'install Jenkins'
sudo apt update 
sudo apt -y install default-jre 
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get -y install jenkins

sudo chown -R jenkins:jenkins /var/www/html
sudo chmod -R 755 /var/www/html
sudo usermod -a -G www-data jenkins
grep 'www-data' /etc/group
groups jenkins

# Iniciar Jenkins
sudo systemctl start jenkins

# anadir poder root al usuario jenkins
echo "jenkins ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers


# descargar de git

if [ "$INSTALL" = "none" ]; then
    echo 'Sin Instalar appnetd_cloud '
elif [ "$INSTALL" != "" ]; then
    echo 'Instalando appnetd_cloud y limpiar antes de empezar'


	cd /var/www/html
	rm -rf *
	rm -rf .*
	sudo apt install -y wget zip
	wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip
	
	echo 'clonar proyecto desde git'
	git clone -b "$INSTALL" https://liviudiaconu@appnet.dev:lss281613858715@github.com/AppNetDeveloper/Cloud-AppNet-Developer.git /var/www/html > /var/www/log.txt
	echo 'instalar .env'
	cp .env.example .env
	export COMPOSER_ALLOW_SUPERUSER=1
	/usr/local/bin/composer update
	echo 'generar con artisan todo lo de la base mysql necesario'
	/usr/bin/npm install -g vite
	php artisan key:generate
	php artisan migrate:fresh 
	#php artisan db:seed UsersAndPermissionsSeeder
	#php artisan db:seed StopCategorySeeder
	#php artisan db:seed StopTypeSeeder
	echo 'limpiar cache'
	php artisan config:clear
	php artisan route:clear
	php artisan view:clear
	echo 'npm install update'
	/usr/bin/npm install
	/usr/bin/npm update
	echo 'dar permiso composer root y instalar y actualizar'
	export COMPOSER_ALLOW_SUPERUSER=1
	/usr/local/bin/composer update
	/usr/bin/npm run prod
	echo 'dar los permisos necesario'
	sudo chmod -R 777 /var/www
	sudo chmod -R 777 *
	sudo chmod -R 777 storage
	sudo chmod -R 777 app/Models
	sudo chmod 777 /var/www/html/storage/logs/
	sudo chmod 777 /var/www/html/storage/framework/sessions
	sudo chmod 777 /var/www/html/storage/framework/views
	echo "limpiar git para que despues el auto update de Jenkins funcione"
	sudo rm -rf .git
else
    echo "Por favor especifica none o install en instalacion "
    exit 1
fi

echo 'add user permisions'
groups jenkins
sudo usermod -a -G apache jenkins
sudo usermod -a -G nginx jenkins
sudo usermod -a -G www-data jenkins
sudo usermod -aG apache jenkins
sudo usermod -aG nginx jenkins
sudo usermod -aG www-data jenkins
sudo chown -R :apache /var/www/html
sudo chown -R :nginx /var/www/html
sudo chown -R :www-data /var/www/html
sudo chmod -R g+rwx /var/www/html
sudo chown -R :apache /var/www/html
sudo chown -R :nginx /var/www/html
sudo chmod -R g+rwx /var/www/html
echo ""  # Imprime una línea en blanco
echo ''
echo ''
echo ''
echo ''
echo ''
echo ''
echo ''
echo ''
echo ''
echo ''
echo ''
if [ "$VPN" = "none" ]; then
    echo 'Sin VPN P2P Zerotier, Sin abrir Puertos '
elif [ "$VPN" != "" ]; then
    echo 'Installar VPN Zerotier'
	curl -s https://install.zerotier.com | sudo bash
	sudo zerotier-cli join "$VPN"
	sudo zerotier-cli get "$VPN" ip | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
else
    echo "Por favor especifica none o EL ID RED en instalacion "
    exit 1
fi

echo 'Ip:10000 es la interface de WebMin'
if [ "$WEB_SERVER" = "apache" ]; then
    echo 'ip:9999/ApacheGUI/  es el panel de apache. '
elif [ "$WEB_SERVER" = "nginx" ]; then
    echo 'Ip:9000 es la interface de nginx WebGui'
else
    echo "Por favor especifica 'apache' o 'nginx' como argumento al ejecutar este script. Ejemplo: sh install.sh apache o sh install.sh nginx"
    exit 1
fi

if [ "$DB" = "none" ]; then
    echo 'Sin anadir MariaDb '
elif [ "$DB" = "appnetd_cloud" ]; then
    echo 'MariaDb agregada con exito root password: Cvlss2101281613 donde el root tiene la opcion de remote host'
else
    echo "Por favor especifica none o uma en instalacion "
    exit 1
fi


echo 'Contraseña de Jenkins:' 
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo 'jenkins interface : ip:8080'
echo 'servidor web es ip con la ruta de los archivos /www/var/html'

