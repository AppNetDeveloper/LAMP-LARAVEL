#!/bin/sh
cd ~ || exit

DB="$1"
INSTALL="$2"
VPN="$3"
MARIADBPASSWORD="$4"
FTP="$5"
ffmpeg="$6"
opencv="$7"
TensorFlow="$8"
VpnIpOpenCsf="$9"
DOMAIN="$10"
CupsServer="$11"
mqtt="$12"
GitUrl="$13"

if [ "$DB" = "none" ]; then
    echo "Sin MariaDB...."
elif [ "$DB" != ""]; then
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
    IP=localhost
elif [ "$VPN" != "" ]; then
    echo 'Installar VPN Zerotier'
    rm /etc/apt/sources.list.d/zerotier*
    sudo pt remove --yes zerotier-one
    sudo curl -s https://install.zerotier.com | sudo bash
    sudo zerotier-cli join "$VPN"
    sudo zerotier-cli get "$VPN" ip | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
    IP=$(sudo zerotier-cli get "$VPN" ip | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
    echo "IP ZEROTIER: $IP"
else
    echo "Por favor especifica none o EL ID RED en instalacion "
    exit 1
fi

if [ "$FTP" = "install" ]; then
    echo "Instalando ftp server..."
elif [ "$FTP" = "none" ]; then
    echo "Sin instalar ftp server..."
else
    if [ "$FTP" != "" ]; then
        echo "Usar propio servidor FTP"

        # Valor Usuario:contraseña
        # Separar en dos variables
        FTP_USER=$(echo "$FTP" | cut -d ':' -f 1)
        FTP_PASSWORD=$(echo "$FTP" | cut -d ':' -f 2)

        # Mostrar los valores separados
        echo "Usuario: $FTP_USER"
        echo "Contraseña: $FTP_PASSWORD"
    else
        echo "Por favor especifica 'install' para instalar ftp server en local, 'none' sin instalar, o 'usuario:contraseña' si ya dispones de un ftp server"
        exit 1
    fi
fi

if [ "$ffmpeg" = "install" ]; then
    echo "Instalando ffmpeg.."
elif [ "$ffmpeg" = "none" ]; then
    echo "Instalando ffmpeg..."
else
    echo "Por favor especifica 'install' o 'none' donde install install ffmpeg y none sin instalar ffmpeg"
    exit 1
fi

if [ "$opencv" = "install" ]; then
    echo "Instalando opencv.."
elif [ "$opencv" = "none" ]; then
    echo "Sin opencv..."
else
    echo "Por favor especifica 'install' o 'none' donde install install opencv y none sin instalar opencv"
    exit 1
fi

if [ "$TensorFlow" = "install" ]; then
    echo "Instalando TensorFlow.."
elif [ "$TensorFlow" = "none" ]; then
    echo "Instalando TensorFlow.."
else
    echo "Por favor especifica 'install' o 'none' donde install install TensorFlow y none sin instalar TensorFlow"
    exit 1
fi

sudo apt-get update
sudo apt-get -y install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Obtener la arquitectura de la CPU
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    echo "**Añadiendo repositorios Debian nonfree para x86_64 (Debian 12)**"

    # Añadir la línea "deb http://deb.debian.org/debian bookworm main contrib non-free" al archivo /etc/apt/sources.list
    echo "deb http://deb.debian.org/debian bookworm main contrib non-free" | sudo tee -a /etc/apt/sources.list

    # Actualizar la lista de paquetes
    sudo apt update

elif [ "$ARCH" = "aarch64" ]; then
    echo "**Añadiendo repositorios Debian nonfree para aarch64 (Debian 12)**"

    # Añadir la línea "deb http://deb.debian.org/debian bookworm main contrib non-free"  al archivo /etc/apt/sources.list
    echo "deb http://deb.debian.org/debian bookworm main contrib non-free" | sudo tee -a /etc/apt/sources.list
    echo "deb [arch=armhf] http://httpredir.debian.org/debian/ buster main contrib non-free" | sudo tee -a /etc/apt/sources.list
    # Actualizar la lista de paquetes
    sudo apt update

else
    echo "**Arquitectura de CPU no compatible: $ARCH**"
    echo "Este script solo funciona en sistemas x86_64 o aarch64."
    exit 1
fi


echo " python necesarios"

pip install pymodbus requests Flask numpy pandas flask-cors paho-mqtt setuptools-rust cupy tensorflow torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113 --break-system-package

echo "**Repositorios Debian nonfree añadidos correctamente (Debian 12)**"

# Crear una copia de seguridad del archivo sources.list
cp /etc/apt/sources.list /etc/apt/sources.list.bak

# Eliminar líneas duplicadas
sed -i 'd/^\s*\#/g' /etc/apt/sources.list # Eliminar líneas de comentario
sed -i 'd/\s*$/g' /etc/apt/sources.list   # Eliminar líneas vacías
sort /etc/apt/sources.list | uniq -d >/tmp/sources.list.uniq

# Reemplazar el archivo sources.list con la versión depurada
mv /tmp/sources.list.uniq /etc/apt/sources.list

# Actualizar la caché de paquetes
sudo apt update

sudo apt-get -y update
sudo apt-get -y upgrade # Uncomment this line to install the newest versions of all packages currently installed
# sudo apt-get -y dist-upgrade  # Uncomment this line to, in addition to 'upgrade', handles changing dependencies with new versions of packages
sudo apt-get -y autoremove # Uncomment this line to remove packages that are now no longer needed
systemctl daemon-reload

# Crear directorio de instalación
sudo rm -rf /var/www/html/
sudo mkdir /var/www/
sudo mkdir /var/www/html

# Instalar sudo
apt -y install sudo

# 1. INSTALL THE NGINX
echo "Instalando Nginx..."
# Aquí va el código para instalar Nginx.

# Crear una copia de seguridad del archivo sources.list
cp /etc/apt/sources.list /etc/apt/sources.list.bak

# Eliminar líneas duplicadas
sed -i 'd/^\s*\#/g' /etc/apt/sources.list # Eliminar líneas de comentario
sed -i 'd/\s*$/g' /etc/apt/sources.list   # Eliminar líneas vacías
sort /etc/apt/sources.list | uniq -d >/tmp/sources.list.uniq

# Reemplazar el archivo sources.list con la versión depurada
mv /tmp/sources.list.uniq /etc/apt/sources.list

# Actualizar la caché de paquetes
sudo apt update

sudo apt -y purge apache
sudo apt -y purge apache2
sudo apt -y purge nginx

sudo apt-get install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev openssl libgd-dev libgeoip-dev libperl-dev wget

sudo apt -y install wget

wget http://nginx.org/download/nginx-1.27.0.tar.gz
tar -zxvf nginx-1.27.0.tar.gz
mkdir /etc/nginx
cd nginx-1.27.0 || exit
mv * /etc/nginx/
cd /etc/nginx/ || exit

./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-file-aio \
    --with-http_v2_module \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-http_slice_module

make
sudo make install
sudo useradd -r nginx
sudo mkdir /var/cache/nginx
sudo touch /var/cache/nginx/client_temp
sudo touch /var/cache/nginx/proxy_temp
sudo touch /var/cache/nginx/fastcgi_temp
sudo touch /var/cache/nginx/uwsgi_temp
sudo touch /var/cache/nginx/scgi_temp

# Crear el archivo fastcgi.conf y agregar el contenido
sudo mkdir /etc/nginx/snippets
cat <<EOL >/etc/nginx/snippets/fastcgi-php.conf
# regex para dividir $uri en $fastcgi_script_name y $fastcgi_path
fastcgi_split_path_info ^(.+\.php)(/.+)$;

# Verificar que el script PHP existe antes de pasarlo
try_files \$fastcgi_script_name =404;

# Evitar que try_files reinicie $fastcgi_path_info
# ver: http://trac.nginx.org/nginx/ticket/321
set \$path_info \$fastcgi_path_info;
fastcgi_param PATH_INFO \$path_info;

fastcgi_index index.php;
include fastcgi.conf;
EOL

# Crear el archivo de servicio de systemd para Nginx
sudo bash -c 'cat << EOF > /etc/systemd/system/nginx.service
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target
        
[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true
        
[Install]
WantedBy=multi-user.target
EOF'

# Recargar systemd para que reconozca el nuevo servicio
sudo systemctl daemon-reload
# Habilitar el servicio para que se inicie automáticamente al arrancar el sistema
sudo systemctl enable nginx
# Iniciar el servicio de Nginx
sudo systemctl start nginx
sudo systemctl restart nginx
echo "El servicio de Nginx ha sido creado y está en ejecución."

# 2. INSTALL THE NGINX CONFIGURATION FILES
mkdir /etc/nginx/sites-available
mkdir /etc/nginx/sites-enabled
sudo chmod 755 -R /var/www/html/
sudo chown www-data:www-data -R /var/www/html/

#backup conf
echo 'hacemos una copia de nginx conf antes de poner la nueva'
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.back
sudo mv /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default.back

# Crear un nuevo archivo de configuración con todas las optimizacion de gzip para aumentar velocidad de carga
sudo bash -c 'cat > /etc/nginx/nginx.conf << EOL
user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 768;
	multi_accept on;
}

http {
    sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	client_header_timeout 3m;
	client_body_timeout 3m;
	client_max_body_size 256m;
	client_header_buffer_size 4k;
	client_body_buffer_size 256k;
	large_client_header_buffers 4 32k;
	send_timeout 3m;
	keepalive_timeout 60 60;
	reset_timedout_connection       on;
	server_names_hash_max_size 1024;
	server_names_hash_bucket_size 1024;
	ignore_invalid_headers on;
	connection_pool_size 256;
	request_pool_size 4k;
	output_buffers 4 32k;
	postpone_output 1460;

	include mime.types;
	default_type application/octet-stream;

	# SSL Settings
	ssl_session_cache   shared:SSL:10m;
	ssl_protocols       TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;
	ssl_ciphers        "EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH+aRSA!RC4:EECDH:!RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS";

    access_log /var/log/nginx/access.log;

    gzip on;

    gzip_vary on;
    gzip_proxied any;
    gzip_proxied expired no-cache no-store private auth;
    gzip_comp_level 9;
    gzip_buffers 8 64k;
    gzip_http_version 1.1;
    gzip_min_length 256;
    gzip_types text/plain text/css application/javascript text/xml application/xml application/xml+rss application/atom+xml application/geo+json application/x-javascript application/ld+json application/geo+json; # Se eliminó la duplicación de "application/json"
    gzip_disable "MSIE [1-6]\.";


	# Proxy settings
	proxy_redirect      off;
	proxy_set_header    Host            \$host;
	proxy_set_header    X-Real-IP       \$remote_addr;
	proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
	proxy_pass_header   Set-Cookie;
	proxy_connect_timeout   300;
	proxy_send_timeout  300;
	proxy_read_timeout  300;
	proxy_buffers       32 4k;
	proxy_cache_path /var/cache/nginx levels=2 keys_zone=cache:10m inactive=60m max_size=512m;
	proxy_cache_key "\$host\$request_uri \$cookie_user";
	proxy_temp_path  /var/cache/nginx/temp;
	proxy_ignore_headers Expires Cache-Control;
	proxy_cache_use_stale error timeout invalid_header http_502;
	proxy_cache_valid any 1d;

	open_file_cache_valid 120s;
	open_file_cache_min_uses 2;
	open_file_cache_errors off;
	open_file_cache max=5000 inactive=30s;
	open_log_file_cache max=1024 inactive=30s min_uses=2;

# Logs
log_format main "\$remote_addr - \$remote_user [\$time_local] \$request \$status \$body_bytes_sent \$http_referer \$http_user_agent \$http_x_forwarded_for"; 
log_format bytes "\$body_bytes_sent"; 
#access_log          /var/log/nginx/access.log main;

access_log off;


	# Cache bypass
map \$http_cookie \$no_cache {
	default 0;
	~SESS 1;
	~wordpress_logged_in 1;
}

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-available/*.conf;
	include /etc/nginx/cloudflare.inc;
	include /etc/nginx/fastcgi_params;
}
stream {
    include /etc/nginx/stream.conf.d/*.conf;    
#        include /etc/nginx/cloudflare.inc;
#        include /etc/nginx/fastcgi_params;
}
EOL'
echo 'config con exito'

# Crear un nuevo archivo de configuración
echo 'Crear un nuevo archivo de configuración nginx MEJORADO'
sudo bash -c 'cat > /etc/nginx/sites-available/default.conf << EOL
server {
        listen 80;
        listen [::]:80;

        root /var/www/html/public;

        index index.html index.htm index.nginx-debian.html index.php;

        server_name localhost $IP 127.0.0.1; # Cambia el nombre de servidor si es necesario.

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

sudo bash -c 'cat >  /etc/nginx/sites-available/phpmyadmin.conf << EOL
server {
    listen 8081;
        listen [::]:8081;

    server_name localhost $IP 127.0.0.1; # Cambia el nombre de servidor si es necesario.

    root /var/www/phpmyadmin;

    index index.html index.htm index.nginx-debian.html index.php;



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

# Actualizar configuración de Nginx para default.conf
sudo sed -i "s/server_name localhost.*/server_name localhost $IP 127.0.0.1 $DOMAIN;/" /etc/nginx/sites-available/default.conf

# Actualizar configuración de Nginx para phpmyadmin.conf
sudo sed -i "s/server_name localhost.*/server_name localhost $IP 127.0.0.1 $DOMAIN;/" /etc/nginx/sites-available/phpmyadmin.conf

# Descarga las listas de IPs de Cloudflare (IPv4 e IPv6) y concatena en un solo archivo
curl -sL https://www.cloudflare.com/ips-v4/ https://www.cloudflare.com/ips-v6/ | cat >ipscloudflare.txt

# Ruta al archivo de inclusiones de Cloudflare
cloudflare_inc_file="/etc/nginx/cloudflare.inc"

# Genera el archivo de inclusiones de Cloudflare
{
    echo "# Cloudflare https://www.cloudflare.com/ips"
    grep -E -o '([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}|([0-9a-fA-F]{1,4}:){3,7}[0-9a-fA-F]{1,4}/[0-9]{1,3}' ipscloudflare.txt | while read ip; do
        echo "set_real_ip_from $ip;"
    done
    echo "real_ip_header CF-Connecting-IP;"
} >"$cloudflare_inc_file"

# Habilita IPv6 en Nginx
sed -i 's/#\s*use\s*ipv6;/use\s*ipv6;/' /etc/nginx/nginx.conf

# Mensaje de aviso
echo "¡ATENCIÓN! Revisa el archivo $cloudflare_inc_file para confirmar que se han generado las IPs IPv4 e IPv6 correctamente."

# Definir la ruta del archivo mimes.types
mime_file="/etc/nginx/mime.types"

# Verificar si el archivo ya existe y realizar una copia de seguridad si es necesario
if [ -f "$mime_file" ]; then
    cp "$mime_file" "$mime_file.bak"
fi

# Escribir el contenido en el archivo mimes.types
cat <<EOF >"$mime_file"
types {
    text/html                                        html htm shtml;
    text/css                                         css;
    text/xml                                         xml;
    image/gif                                        gif;
    image/jpeg                                       jpeg jpg;
    application/javascript                           js;
    application/atom+xml                             atom;
    application/rss+xml                              rss;

    text/mathml                                      mml;
    text/plain                                       txt;
    text/vnd.sun.j2me.app-descriptor                 jad;
    text/vnd.wap.wml                                 wml;
    text/x-component                                 htc;

    image/png                                        png;
    image/svg+xml                                    svg svgz;
    image/tiff                                       tif tiff;
    image/vnd.wap.wbmp                               wbmp;
    image/webp                                       webp;
    image/x-icon                                     ico;
    image/x-jng                                      jng;
    image/x-ms-bmp                                   bmp;

    font/woff                                        woff;
    font/woff2                                       woff2;

    application/java-archive                         jar war ear;
    application/json                                 json;
    application/mac-binhex40                         hqx;
    application/msword                               doc;
    application/pdf                                  pdf;
    application/postscript                           ps eps ai;
    application/rtf                                  rtf;
    application/vnd.apple.mpegurl                    m3u8;
    application/vnd.google-earth.kml+xml             kml;
    application/vnd.google-earth.kmz                 kmz;
    application/vnd.ms-excel                         xls;
    application/vnd.ms-fontobject                    eot;
    application/vnd.ms-powerpoint                    ppt;
    application/vnd.oasis.opendocument.graphics      odg;
    application/vnd.oasis.opendocument.presentation  odp;
    application/vnd.oasis.opendocument.spreadsheet   ods;
    application/vnd.oasis.opendocument.text          odt;
    application/vnd.openxmlformats-officedocument.presentationml.presentation
                                                     pptx;
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
                                                     xlsx;
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
                                                     docx;
    application/vnd.wap.wmlc                         wmlc;
    application/wasm                                 wasm;
    application/x-7z-compressed                      7z;
    application/x-cocoa                              cco;
    application/x-java-archive-diff                  jardiff;
    application/x-java-jnlp-file                     jnlp;
    application/x-makeself                           run;
    application/x-perl                               pl pm;
    application/x-pilot                              prc pdb;
    application/x-rar-compressed                     rar;
    application/x-redhat-package-manager             rpm;
    application/x-sea                                sea;
    application/x-shockwave-flash                    swf;
    application/x-stuffit                            sit;
    application/x-tcl                                tcl tk;
    application/x-x509-ca-cert                       der pem crt;
    application/x-xpinstall                          xpi;
    application/xhtml+xml                            xhtml;
    application/xspf+xml                             xspf;
    application/zip                                  zip;

    application/octet-stream                         bin exe dll;
    application/octet-stream                         deb;
    application/octet-stream                         dmg;
    application/octet-stream                         iso img;
    application/octet-stream                         msi msp msm;

    audio/midi                                       mid midi kar;
    audio/mpeg                                       mp3;
    audio/ogg                                        ogg;
    audio/x-m4a                                      m4a;
    audio/x-realaudio                                ra;

    video/3gpp                                       3gpp 3gp;
    video/mp2t                                       ts;
    video/mp4                                        mp4;
    video/mpeg                                       mpeg mpg;
    video/quicktime                                  mov;
    video/webm                                       webm;
    video/x-flv                                      flv;
    video/x-m4v                                      m4v;
    video/x-mng                                      mng;
    video/x-ms-asf                                   asx asf;
    video/x-ms-wmv                                   wmv;
    video/x-msvideo                                  avi;
}
EOF

# Imprimir un mensaje de éxito
echo "Archivo mimes.types generado con éxito en $mime_file"

sudo ufw allow 8081

echo 'config con exito'

# Reiniciar Nginx
systemctl restart nginx && systemctl enable nginx

#Composer Install
sudo apt -y install -y curl php-cli php-mbstring git unzip
cd ~ || exit
curl -sS https://getcomposer.org/installer -o composer-setup.php
HASH=$(curl -sS https://composer.github.io/installer.sig)
php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer

#NPM install
sudo apt -y install -y nodejs npm

# 2. INSTALL THE DEPENDENCIES

# Build tools:
sudo apt-get install -y build-essential
sudo apt-get install -y cmake

# GUI (if you want to use GTK instead of Qt, replace 'qt5-default' with 'libgtkglext1-dev' and remove '-DWITH_QT=ON' option in CMake):
sudo apt-get install -y qt5-default
sudo apt-get install -y libvtk6-dev

# Media I/O:
sudo apt-get install -y zlib1g-dev
sudo apt-get install -y libjpeg-dev
sudo apt-get install -y libwebp-dev
sudo apt-get install -y libpng-dev
sudo apt-get install -y libtiff5-dev
sudo apt-get install -y libjasper-dev
sudo apt-get install -y libopenexr-dev
sudo apt-get install -y libgdal-dev

# Video I/O:
sudo apt-get install -y libdc1394-22-dev
sudo apt-get install -y libavcodec-dev
sudo apt-get install -y libavformat-dev
sudo apt-get install -y libswscale-dev
sudo apt-get install -y libtheora-dev
sudo apt-get install -y libvorbis-dev
sudo apt-get install -y libxvidcore-dev
sudo apt-get install -y libx264-dev
sudo apt-get install -y yasm
sudo apt-get install -y libopencore-amrnb-dev
sudo apt-get install -y libopencore-amrwb-dev
sudo apt-get install -y libv4l-dev
sudo apt-get install -y libxine2-dev

# Parallelism and linear algebra libraries:
sudo apt-get install -y libtbb-dev
sudo apt-get install -y libeigen3-dev

# Python:
sudo apt-get install -y python-dev
sudo apt-get install -y python-tk
sudo apt-get install -y python-numpy
sudo apt-get install -y python3-dev
sudo apt-get install -y python3-tk
sudo apt-get install -y python3-numpy

# Java:
sudo apt-get install -y ant default-jdk

# Documentation:
sudo apt-get install -y doxygen

#WHOIS
sudo apt -y install whois

#Necesarios OpenCV
sudo apt -y install build-essential
sudo apt -y cmake pkg-config
sudo apt -y libjpeg-dev
sudo apt -y libpng-dev
sudo apt -y libtiff-dev
sudo apt -y libjasper-dev
sudo apt -y libavcodec-dev
sudo apt -y libavformat-dev
sudo apt -y libswscale-dev
sudo apt -y libgstreamer1.0-dev
sudo apt -y libgstreamer-plugins-base1.0-dev
sudo apt -y libv4l2-dev
sudo apt -y python3-dev
sudo apt -y python3-numpy

sudo apt -y install libopencv-dev python3-opencv
python3 -c "import cv2; print(cv2.__version__)"

apt -y install graphicsmagick-imagemagick-compat
apt -y install imagemagick
# Instalar dependencias
sudo apt-get install -y autoconf
sudo apt-get install -y build-essential
sudo apt-get install -y libass-dev
sudo apt-get install -y libdav1d-dev
sudo apt-get install -y libmp3lame-dev
sudo apt-get install -y yasm
sudo apt-get install -y libopus-dev
sudo apt-get install -y openssl
sudo apt-get install -y libssl-dev

# Obtener otras dependencias
sudo apt-get install -y autoconf
sudo apt-get install -y automake
sudo apt-get install -y build-essential
sudo apt-get install -y cmake
sudo apt-get install -y git
sudo apt-get install -y libass-dev
sudo apt-get install -y libfreetype6-dev
sudo apt-get install -y libgnutls28-dev
sudo apt-get install -y libmp3lame-dev
sudo apt-get install -y libsdl2-dev
sudo apt-get install -y libtool
sudo apt-get install -y libva-dev
sudo apt-get install -y libvdpau-dev
sudo apt-get install -y libvorbis-dev
sudo apt-get install -y libxcb1-dev
sudo apt-get install -y libxcb-shm0-dev
sudo apt-get install -y libxcb-xfixes0-dev
sudo apt-get install -y meson
sudo apt-get install -y ninja-build
sudo apt-get install -y pkg-config
sudo apt-get install -y texinfo
sudo apt-get install -y wget
sudo apt-get install -y yasm
sudo apt-get install -y zlib1g-dev
sudo apt -y install libchromaprint-tools
sudo apt -y install frei0r-plugins-dev
sudo apt -y install qttools5-dev qttools5-dev-tools
sudo apt -y install libqt5svg5-dev
sudo apt -y install ladspa-sdk git cmake
sudo apt -y install libsndfile1-dev libsamplerate-ocaml-dev
sudo apt -y install libjack-jackd2-dev
sudo apt -y install libxml* freetype* fontconfig*
sudo apt-get -y install libbluray-bdj libbluray-* libbluray-dev
sudo apt -y install libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libavresample-dev
sudo apt -y install liblilv-0-0 liblilv-dev lilv-utils
sudo apt -y install libiec61883-dev libraw1394-tools libraw1394-doc libraw1394-dev libraw1394-tools
sudo apt -y install libavc1394-0 libavc1394-dev libavc1394-tools
sudo apt -y install libbluray-dev libbluray-doc libbluray-bin
sudo apt -y install libbs2b-dev libbs2b0
sudo apt -y install libcaca-dev
sudo apt -y install libdc1394-22-dev
sudo apt -y install libgme-dev
sudo apt -y install libgsm1-dev
sudo apt -y install libmodplug-dev
sudo apt -y install libmp3lame-dev
sudo apt -y install libopencore-amrnb-dev
sudo apt -y install libopencore-amrwb-dev
sudo apt -y install libopenexr-dev
sudo apt -y install libopenjp2-7-dev
sudo apt -y install libopus-dev
sudo apt -y install librtmp-dev
sudo apt -y install librubberband-dev
sudo apt -y install libsoxr-dev
sudo apt -y install libspeex-dev
sudo apt -y install libtheora-dev
sudo apt -y install libtwolame-dev
sudo apt -y install libvorbis-dev
sudo apt -y install libvpx-dev
sudo apt -y install libx264-dev
sudo apt -y install libx265-dev
sudo apt -y install libxvidcore-dev
sudo apt -y install libzmq3-dev
sudo apt -y install libzvbi-dev
sudo apt -y install libzvbi0
sudo apt -y install libxine2-dev
sudo apt -y install flite1-dev libflite-dev
sudo apt -y install libopenal-dev libopenal0
sudo apt -y install libopenmpt-dev libopenmpt0
sudo apt -y install libshine-dev libshine1
sudo apt -y install libvidstab-dev
sudo apt -y install libva-dev
sudo apt -y install libva-drm-dev
sudo apt -y install libva-x11-dev
sudo apt -y install libvdpau-dev
sudo apt -y install libvdpau-va-gl1
sudo apt -y install libvmaf-dev
sudo apt -y install libwebp-dev
sudo apt -y install libsnappy-dev
sudo apt -y install libcdio-dev
sudo apt -y install git-all cmake cmake-curses-gui build-essential gcc-arm-linux-gnueabi g++-arm-linux-gnueabi yasmapt install cdparanoia
sudo apt -y install cdparanoia
sudo apt-get install -y libcdio-utils
sudo apt -y install libcdparanoia-dev libcdparanoia0
sudo apt -y install libcdio-paranoia libcdio-paranoia-dev

# Instalar NASM
sudo apt-get -y install nasm

sudo apt -y install libx264-dev
sudo apt -y install libx265-dev

# Instalar openssl
sudo apt -y install openssl libssl-dev

sudo apt -y install libsvtav1-dev

# Save existing php package list to packages.txt file
sudo dpkg -l | grep php | tee packages.txt

# Add Ondrej's repo source and signing key along with dependencies
sudo apt -y install -y apt-transport-https ca-certificates gnupg2 software-properties-common lsb-release

sudo curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

sudo add-apt-repository -y ppa:ondrej/php <<EOF

EOF

## Remove old packages
sudo apt -y remove --purge php*
sudo apt -y purge php*
sudo apt -y autoremove --purge

# Instalar curl y wget
sudo apt -y install -y curl wget

sudo wget -qO /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
sudo echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list

# Descargar la clave GPG para el repositorio de PHP
sudo wget -qO /etc/apt/trusted.gpg.d/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg

# Agregar la clave de Zend
curl -s https://repos.zend.com/zend.key | gpg --dearmor >/usr/share/keyrings/zend.gpg

# Añadir el repositorio de PHP a la lista de fuentes de paquetes
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list

# Descargar la clave GPG para el repositorio de PHP de nuevo (parece repetitivo, puede ser necesario sólo una vez)
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg

# Añadir el repositorio de PHP a la lista de fuentes de paquetes de nuevo (también parece repetitivo, puede ser necesario sólo una vez)
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" >/etc/apt/sources.list.d/php.list

# Crear una copia de seguridad del archivo sources.list
cp /etc/apt/sources.list /etc/apt/sources.list.bak

# Eliminar líneas duplicadas
sed -i 'd/^\s*\#/g' /etc/apt/sources.list # Eliminar líneas de comentario
sed -i 'd/\s*$/g' /etc/apt/sources.list   # Eliminar líneas vacías
sort /etc/apt/sources.list | uniq -d >/tmp/sources.list.uniq

# Reemplazar el archivo sources.list con la versión depurada
mv /tmp/sources.list.uniq /etc/apt/sources.list

# Actualizar los paquetes
sudo apt-get -y update
sudo apt-get -y upgrade # Uncomment this line to install the newest versions of all packages currently installed
# sudo apt-get -y dist-upgrade  # Uncomment this line to, in addition to 'upgrade', handles changing dependencies with new versions of packages
sudo apt-get -y autoremove # Uncomment this line to remove packages that are now no longer needed
systemctl daemon-reload

# Instalar PHP y las extensiones necesarias
sudo apt -y install php8.3-phar
sudo apt -y install php8.3-common
sudo apt -y install php8.3
sudo apt -y install php8.3-fpm
sudo apt -y install php8.3-mysql
sudo apt -y install php8.3-curl
sudo apt -y install php8.3-gd
sudo apt -y install php8.3-imagick
sudo apt -y install php8.3-intl
sudo apt -y install php8.3-mysql
sudo apt -y install php8.3-mbstring
sudo apt -y install php8.3-xml
sudo apt -y install php8.3-mcrypt
sudo apt -y install php-mcrypt
sudo apt -y install php8.3-zip
sudo apt -y install php8.3-ldap
sudo apt -y install php8.3-sybase
sudo apt -y install php8.3-opcache
sudo apt -y install php8.3-pgsql
sudo apt -y install php8.3-redis
sudo apt -y install php8.3-common
sudo apt -y install php8.3
sudo apt -y install php8.3-cli
sudo apt -y install php8.3-curl
sudo apt -y install php8.3-bz2
sudo apt -y install php8.3-xml
sudo apt -y install php8.3-mysql
sudo apt -y install php8.3-gd
sudo apt -y install php8.3-imagick
sudo apt -y install php-bz2
sudo apt -y install php8.3-mbstring
sudo apt -y install php8.3-intl
sudo apt -y install php8.3-opcache
sudo apt -y install php8.3-curl
sudo apt -y install php-curl
sudo apt -y install php-zip
sudo apt -y install php8.3-zip
sudo apt -y install php-ssh2
sudo apt -y install php8.3-ssh2
sudo apt -y install php-xmlrpc
sudo apt -y install php-xml
sudo apt -y install php-curl
sudo apt -y install php-mbstring
sudo apt -y install php8.3-fpm
sudo apt -y install php8.3-curl

sudo systemctl restart php8.3-fpm
sudo systemctl enable php8.3-fpm

sudo a2disconf php*-fpm
# On Apache: Enable PHP 8.3 FPM
sudo a2enconf php8.3-fpm

sudo apt-get install php-pear
sudo apt-get install php8.3-pear
sudo pecl channel-update pecl.php.net

sudo systemctl restart php8.3-fpm && sudo systemctl enable php8.3-fpm

sudo pear config-set php_bin /usr/bin/php8.3

# Añadir la clave de Microsoft
sudo curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

# Añadir los repositorios de Microsoft
sudo pecl install sqlsrv
sudo pecl install pdo_sqlsrv
sudo pecl install pdo_mysql
sudo pecl install pdo_pgsql
sudo phpenmod -v 8.3 sqlsrv pdo_sqlsrv

sudo curl https://packages.microsoft.com/config/debian/12/prod.list >/etc/apt/sources.list.d/mssql-release.list
sudo curl https://packages.microsoft.com/config/debian/11/prod.list >/etc/apt/sources.list.d/mssql-release.list
sudo curl https://packages.microsoft.com/config/debian/9/prod.list >/etc/apt/sources.list.d/mssql-release.list

# Instalar las herramientas de Microsoft SQL
sudo apt-get -y install msodbcsql17
sudo apt-get -y install mssql-tools
sudo apt-get -y install unixodbc-dev
sudo apt-get -y install php-dev

# Instalar las extensiones PHP para Microsoft SQL
sudo pecl install pdo_sqlsrv
sudo pecl install sqlsrv

# Habilitar las extensiones PHP para Microsoft SQL
echo "; priority=20\nextension=sqlsrv.so\n" >/etc/php/8.3/mods-available/sqlsrv.ini
echo "; priority=30\nextension=pdo_sqlsrv.so\n" >/etc/php/8.3/mods-available/pdo_sqlsrv.ini
sudo phpenmod -v 8.3 sqlsrv pdo_sqlsrv

sudo apt -y install gcc
sudo apt -y install -y g++
sudo apt -y install -y make

sudo apt -y install curl gnupg2 ca-certificates lsb-release debian-archive-keyring
sudo apt -y install curl gnupg2 ca-certificates lsb-release ubuntu-keyring
#Esta nueva version anade estos dos parametros directamente en la instalcion por ser repo de microsoft
#echo "extension=sqlsrv" | sudo tee -a /etc/php/8.3/cli/php.ini
#echo "extension=pdo_sqlsrv" | sudo tee -a /etc/php/8.3/cli/php.ini

# Reiniciar Nginx
systemctl restart nginx
# Añade las líneas al archivo www.conf
echo "pm.max_children = 250" | sudo tee -a /etc/php/8.3/fpm/pool.d/www.conf
echo "pm.max_requests = 500" | sudo tee -a /etc/php/8.3/fpm/pool.d/www.conf
echo "pm.start_servers = 50" | sudo tee -a /etc/php/8.3/fpm/pool.d/www.conf
echo "pm.min_spare_servers = 50" | sudo tee -a /etc/php/8.3/fpm/pool.d/www.conf
echo "pm.max_spare_servers = 200" | sudo tee -a /etc/php/8.3/fpm/pool.d/www.conf
echo "process.priority = -19" | sudo tee -a /etc/php/8.3/fpm/pool.d/www.conf
echo "php_value[memory_limit] = 512M" | sudo tee -a /etc/php/8.3/fpm/pool.d/www.conf

# Añade las líneas al archivo php.ini
echo "memory_limit=4096M" | sudo tee -a /etc/php/8.3/cli/php.ini
echo "date.timezone=Europe/Madrid" | sudo tee -a /etc/php/8.3/cli/php.ini
echo "post_max_size=20000M" | sudo tee -a /etc/php/8.3/cli/php.ini
echo "upload_max_filesize=20000M" | sudo tee -a /etc/php/8.3/cli/php.ini
echo "max_execution_time=180000" | sudo tee -a /etc/php/8.3/cli/php.ini
echo "max_input_time=12000" | sudo tee -a /etc/php/8.3/cli/php.ini

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
sudo systemctl restart nginx

curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - &&
    sudo apt-get install -y nodejs

# Descargar e instalar NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# Recargar la configuración de Bash
source ~/.bashrc

nvm list-remote
# Instalar la versión LTS más reciente de Node.js
nvm install --lts # pones 22 si quieres instalar 22 en lugar de --lts versión LTS más reciente

nvm use 'lts/*' # pones 22 si quieres instalar 22 en lugar de --lts：
# Establecer la versión LTS recién instalada como la predeterminada
nvm alias default 'lts/*'

#INSTALL FFMPEG SOLO SI ES INSTALL

if [ "$ffmpeg" = "install" ]; then
    sudo apt install ffmpeg

fi

sudo apt -y install python3-venv python3-dev -y

# install opencv
if [ "$opencv" = "install" ]; then
    echo "Instalando opencv.."

    wget https://bootstrap.pypa.io/get-pip.py
    sudo python3 get-pip.py
    sudo apt install -y libopencv-dev
    sudo apt-get -y install python3-pip
    pip3 install opencv-contrib-python --break-system-packages
    sudo apt-get install -y python3-opencv
    pip3 install opencv-contrib-python --break-system-packages

    # final opencv

fi

# Install tensorflow
if [ "$TensorFlow" = "install" ]; then
    echo "Instalando tensorflow.."

    pip install --upgrade pip setuptools wheel --break-system-packages

    # Obtener la arquitectura de la CPU
    ARCH=$(uname -m)

    if [ "$ARCH" = "x86_64" ]; then
        echo "**Instalando TensorFlow para x86_64**"

        # Instalar Python 3 y pip
        sudo apt update
        sudo apt -y install -y python3 python3-pip python3-venv

        # Instalar TensorFlow con soporte para GPU
        pip install --upgrade pip
        pip install tensorflow --break-system-packages

        # Verificar la instalación de TensorFlow
        python3 -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
        pip install tensorflow --break-system-packages

    elif [ "$ARCH" = "aarch64" ]; then
        echo "**Instalando TensorFlow para aarch64**"

        # Instalar Python 3 y pip
        sudo apt update
        sudo apt -y install -y python3 python3-pip python3-venv --break-system-packages

        # Crear un entorno virtual y activarlo
        python3 -m venv tf_env
        source tf_env/bin/activate

        # Instalar TensorFlow optimizado para ARM
        python3 -m pip install tensorflow[and-cuda] --break-system-packages
        pip install tensorflow-cpu-aws --break-system-packages

        # Verificar la instalación de TensorFlow
        python3 -c "import tensorflow as tf; print(tf.config.list_physical_devices('CPU'))"

    else
        echo "**Arquitectura de CPU no compatible: $ARCH**"
        echo "Este script solo funciona en sistemas x86_64 o aarch64."
        exit 1
    fi

    echo "**TensorFlow instalado correctamente para $ARCH**"

    # Salir del entorno virtual (si se creó para aarch64)
    if [ "$ARCH" = "aarch64" ]; then
        deactivate
    fi

    # Final install tensorflow

fi

if([ "$mqtt" = "install" ])
then
    echo "Instalando cMosquitto.."


# Instalar Mosquitto y el cliente Mosquitto
echo "Instalando Mosquitto y el cliente..."
sudo apt install -y mosquitto mosquitto-clients

# Crear archivo de configuración en /etc/mosquitto/conf.d/default.conf
echo "Configurando Mosquitto en /etc/mosquitto/conf.d/default.conf..."
cat <<EOL | sudo tee /etc/mosquitto/conf.d/default.conf
allow_anonymous true

listener 1883 0.0.0.0
max_connections 500000
max_inflight_messages 20000
max_queued_messages 100000
autosave_interval 600

listener 8083
protocol websockets
EOL

# Reiniciar el servicio Mosquitto
echo "Reiniciando el servicio Mosquitto..."
sudo systemctl restart mosquitto

# Habilitar Mosquitto para que se inicie al arrancar el sistema
sudo systemctl enable mosquitto

echo "Instalación y configuración de Mosquitto completadas."
fi

# install cups
if [ "$CupsServer" = "install" ]; then
    echo "Instalando cups.."

# Script para instalar y configurar CUPS en Ubuntu Server
sudo apt-get -y install python3-pyqt5
sudo apt-get -y install hplip hplip-data hplip-doc hpijs-ppds hplip-gui hplip-dbg printer-driver-hpcups printer-driver-hpijs printer-driver-pxljr
sudo apt -y install hplip hplip-gui

# Actualizar la lista de paquetes
echo "Actualizando la lista de paquetes..."
sudo apt update

# Instalar CUPS
echo "Instalando CUPS..."
sudo apt install -y cups

# Verificar que CUPS esté corriendo
echo "Verificando el estado de CUPS..."
systemctl status cups --no-pager

# Permitir acceso remoto y configurar CUPS para escuchar en 0.0.0.0
CUPS_CONF="/etc/cups/cupsd.conf"
echo "Configurando CUPS para permitir acceso remoto..."

# Realiza una copia de seguridad del archivo de configuración
sudo cp $CUPS_CONF "${CUPS_CONF}.bak"

# Modificar la configuración de CUPS
# Cambiar 'Listen localhost:631' a 'Listen 0.0.0.0:631'
sudo sed -i 's/^Listen localhost:631/Listen 0.0.0.0:631/' $CUPS_CONF || echo "No se encontró la línea de escucha. Añadiendo..."
echo "Listen 0.0.0.0:631" | sudo tee -a $CUPS_CONF

# Modificar las secciones de acceso para permitir acceso remoto
# Añadir o reemplazar la sección <Location />
sudo sed -i '/<Location \/>/,/<\/Location>/d' $CUPS_CONF
echo "<Location />" | sudo tee -a $CUPS_CONF
echo "  Order allow,deny" | sudo tee -a $CUPS_CONF
echo "  Allow all" | sudo tee -a $CUPS_CONF
echo "</Location>" | sudo tee -a $CUPS_CONF

# Añadir o reemplazar la sección <Location /admin>
sudo sed -i '/<Location \/admin>/,/<\/Location>/d' $CUPS_CONF
echo "<Location /admin>" | sudo tee -a $CUPS_CONF
echo "  Order allow,deny" | sudo tee -a $CUPS_CONF
echo "  Allow all" | sudo tee -a $CUPS_CONF
echo "</Location>" | sudo tee -a $CUPS_CONF

# Reiniciar CUPS para aplicar cambios
echo "Reiniciando CUPS..."
sudo systemctl restart cups

# Asegurarse de que el firewall permite el tráfico en el puerto 631
echo "Configurando el firewall para permitir tráfico en el puerto 631..."
sudo ufw allow 631/tcp

# Mostrar el estado final de CUPS
echo "Estado final de CUPS:"
systemctl status cups --no-pager

echo "CUPS ha sido instalado y configurado correctamente."
echo "Accede a la interfaz web de CUPS en: http://<IP_DEL_SERVIDOR>:631    y para anadir hp sudo hp-setup -i"


fi

echo 'Pasamos a Mariadb'
if [ "$DB" = "none" ]; then
    echo "Sin MariaDB...."
elif [ "$DB" != "" ]; then
    echo "Instalar MariaDB y crear tabla appnetd_cloud"

    if [ -z "$MARIADBPASSWORD" ]; then
        MARIADBPASSWORD=$(
            head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12
            echo ''
        )
    fi

    curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash

    apt install software-properties-common apt-transport-https -y
    curl -fsSL http://mirror.mariadb.org/PublicKey_v2 | sudo gpg --dearmor | sudo tee /usr/share/keyrings/mariadb.gpg >/dev/null
    echo "deb [arch=amd64,arm64,ppc64el signed-by=/usr/share/keyrings/mariadb.gpg] http://mirror.mariadb.org/repo/11.4.2/ubuntu/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mariadb.list
    echo "deb [arch=amd64,arm64,ppc64el signed-by=/usr/share/keyrings/mariadb.gpg] http://mirror.mariadb.org/repo/11.4.2/debian/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mariadb.list

    apt update && apt upgrade -y

    # Update package lists
    sudo apt-get update -y

    echo "Instalo mariadb"

    sudo apt-get -y install mariadb-server mariadb-client
    echo "ejecuto secure"
    # Ejecuta el script de seguridad de MySQL
    sudo mysql_secure_installation <<EOF

y
y
$MARIADBPASSWORD
$MARIADBPASSWORD
y
n
y
y
EOF

    echo " MAriadb Instalado, paro a la config"
    # Inicia el servidor MariaDB
    sudo systemctl stop mariadb
    sudo systemctl start mariadb
    sudo systemctl enable mariadb

    # Crea la base de datos
    echo "CREATE DATABASE ${DB};" | mysql -uroot -p"${MARIADBPASSWORD}"

    # Define tu contraseña

    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADBPASSWORD}';" | mysql -uroot -p"${MARIADBPASSWORD}"

    # Generar usuario y contraseña aleatorios
    NEW_USERNAME="usuario$(date +%s)"
    NEW_PASSWORD=$(
        head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12
        echo ''
    )

    # Asignar usuario y contraseña a la base de datos
    echo "CREATE USER '${NEW_USERNAME}'@'localhost' IDENTIFIED BY '${NEW_PASSWORD}';" | mysql -uroot -p"${MARIADBPASSWORD}" "${DB}"
    echo "GRANT ALL PRIVILEGES ON ${DB}.* TO '${NEW_USERNAME}'@'localhost';" | mysql -uroot -p"${MARIADBPASSWORD}" "${DB}"

    # Mostrar usuario y contraseña generados
    echo "Usuario: ${NEW_USERNAME}"
    echo "Contraseña: ${NEW_PASSWORD}"

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

    sudo mkdir /var/www/phpmyadmin/tmp
    sudo chmod 777 /var/www/phpmyadmin/tmp

    # Reiniciamos el servicio para que los cambios tengan efecto
    sudo systemctl restart mariadb

else
    echo "Por favor especifica 'none' o 'appnetd_cloud' como argumento al ejecutar este script. Ejemplo: sh install.sh apache none o uma o sh install.sh nginx none o uma"
    exit 1
fi

#redis
sudo apt -y install redis-server
sudo systemctl enable --now redis-server.service
echo "Redis Instalado, paro a la config"
echo "Instalando appnetd_cloud y limpiar antes de empezar"
cd /var/www/ || exit
echo "he pasado a carpeta /var/www"
echo "limpiando carpeta html"
#Comprobar si el directorio existe
if [ -d "/var/www/html/" ]; then
    # Si el directorio existe, cambiar a él y eliminar su contenido
    cd /var/www/ || exit
    rm -rf html/*
else
    # Si el directorio no existe, salir del script
    echo "El directorio /var/www/html/ no existe."

fi
echo "he limpiado carpeta html"
echo "instalor ftp y sftp"
#Installar servidor ftp y sftp
if [ "$FTP" = "install" ]; then
    # Función para generar una contraseña segura
    echo "Función para generar una contraseña segura"
    generate_FTP_PASSWORD() {
        openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 16
    }

    # Generar nombre de usuario y contraseña aleatorios
    FTP_USER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
    FTP_PASSWORD=$(generate_FTP_PASSWORD)
    FTP_DIR=/var/www/ftp
    echo "FTP_USER: $FTP_USER"
    echo "FTP_PASSWORD: $FTP_PASSWORD"
    echo "FTP_DIR: $FTP_DIR"
    echo "FTP_USER: $FTP_USER"
    echo "FTP_PASSWORD: $FTP_PASSWORD"
    # Actualizar e instalar paquetes necesarios
    sudo apt -y install -y proftpd
    echo "Configuro config ftp"
    # Configurar ProFTPD
    cp /etc/proftpd/proftpd.conf /etc/proftpd/proftpd.conf.backup
    sed -i 's/^DefaultRoot .*/DefaultRoot ~/g' /etc/proftpd/proftpd.conf
    sed -i 's/^# DefaultRoot .*/DefaultRoot ~/g' /etc/proftpd/proftpd.conf
    sed -i 's/^RequireValidShell.*/RequireValidShell off/g' /etc/proftpd/proftpd.conf
    sed -i 's/^# RequireValidShell.*/RequireValidShell off/g' /etc/proftpd/proftpd.conf
    sed -i 's/^PassivePorts.*/PassivePorts 50000 50010/g' /etc/proftpd/proftpd.conf
    sed -i 's/^# PassivePorts.*/PassivePorts 50000 50010/g' /etc/proftpd/proftpd.conf

    echo "paso a directorio y usuario"

    # Crear el directorio FTP si no existe
    sudo mkdir -p "$FTP_DIR"
    echo "Directorio $FTP_DIR creado."

    # Crear el usuario sin crear el directorio de inicio si ya existe
    sudo useradd -M -d $FTP_DIR -s /bin/bash $FTP_USER
    # Establecer la contraseña del usuario utilizando chpasswd
    echo "$FTP_USER:$FTP_PASSWORD" | sudo chpasswd
    # Agregar al usuario al grupo propietario del directorio
    sudo usermod -aG $(stat -c '%G' $FTP_DIR) $FTP_USER
    # Otorgar permisos de lectura, escritura y ejecución al directorio y a todos los archivos dentro de él
    sudo chmod -R 777 $FTP_DIR
    echo "FTP instalado lo reiniciare"
    # Reiniciar ProFTPD
    sudo systemctl restart proftpd

    echo "He terminado con FTP"

    FTP_HOST='localhost'
    FTP_ROOT='/var/www/ftp/'
    FTP_PORT=21
    FTP_PASSIVE=true
    FTP_THROW=false

fi

sudo systemctl stop ufw
sudo systemctl disable ufw
sudo apt -y purge ufw
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo apt remove ufw -y
sudo apt autoremove -y
sudo apt remove firewalld
sudo apt autoremove -y
sudo apt -y purge firewalld

cd /root/
wget https://download.configserver.com/csf.tgz
tar -xzf csf.tgz
cd csf
sudo ./install.sh
sudo sed -i 's/TESTING = "1"/TESTING = "0"/g' /etc/csf/csf.conf
systemctl start csf
systemctl enable csf
sudo csf -x

# Define los puertos que deseas abrir
PUERTOS="1880,9090,1883,8081,9100,515,631"

# Define la red de VPN
RED_VPN="$VpnIpOpenCsf/24"   # Define la red de VPN

# Ruta al archivo de configuración de CSF
CSF_CONF="/etc/csf/csf.conf"

# Función para agregar puertos solo si no están presentes
agregar_puertos() {
    LOCAL_PORTS=$(grep "^TCP_IN = " $CSF_CONF | cut -d'"' -f2)
    
    for PUERTO in $(echo $PUERTOS | tr ',' ' '); do
        if [[ ! $LOCAL_PORTS =~ (^|,)$PUERTO(,|$) ]]; then
            LOCAL_PORTS="$LOCAL_PORTS,$PUERTO"
        fi
    done

    # Actualizar TCP_IN y TCP_OUT
    sed -i "s/^TCP_IN = \".*\"/TCP_IN = \"$LOCAL_PORTS\"/" $CSF_CONF
    sed -i "s/^TCP_OUT = \".*\"/TCP_OUT = \"$LOCAL_PORTS\"/" $CSF_CONF
}

# Llamar a la función para agregar puertos
agregar_puertos

# Permitir acceso total a la red VPN si no está presente
if ! grep -q "$RED_VPN" /etc/csf/csf.allow; then
    echo "$RED_VPN # Acceso total a la red VPN" >> /etc/csf/csf.allow
fi

# Reiniciar CSF para aplicar los cambios
csf -r

echo "Puertos $PUERTOS abiertos en CSF y acceso total a la red $RED_VPN."

sudo csf -e

sudo apt-get install fail2ban -y
sudo apt-get install clamav clamav-daemon -y
sudo systemctl start clamav-daemon
sudo systemctl enable clamav-daemon
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
sudo apt -y install openssh-server
sudo systemctl start openssh
sudo systemctl enable openssh
sudo apt -y install bridge-utils

#Instalar phpmyadmin
echo "Instalando phpmyadmin"
cd /var/www/ || exit
mkdir phpmyadmin

sudo apt -y install -y wget zip
wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip
sudo unzip phpMyAdmin-5.2.1-all-languages.zip
mv phpMyAdmin-5.2.1-all-languages/* phpmyadmin

# descargar de git
echo "Instalando appnetd_cloud si no es none"

if [ "$INSTALL" = "none" ]; then
    echo 'Sin Instalar appnetd_cloud '
elif [ "$INSTALL" != "" ]; then
    echo 'Instalando appnetd_cloud y limpiar antes de empezar'

    mkdir /var/www/html/
    cd /var/www/html/ || exit

    echo 'clonar proyecto desde git'
    git clone -b "$INSTALL" "$GitUrl" /var/www/html >/var/www/log.txt 2>&1
    echo 'instalar .env'
    cp .env.example .env
    # Ruta del archivo .env
    ENV_FILE=".env"

    # Generar el token de localhost monitor list
    TOKENHOST=$(openssl rand -hex 32)

    # 1. Descargar el archivo de servicio systemd (usando curl)
    curl -L -s "https://appnet.dev/empleado/generador-linux-service.php" >/etc/systemd/system/appnetmonitor.service
    chmod 777 /etc/systemd/system/appnetmonitor.service

    # 2 Descargar el script de monitoreo (usando curl)
    curl -L -s "https://appnet.dev/empleado/generar-linux-sh.php?token=$TOKENHOST&link=$IP" >/root/appnetdev-monitor.sh
    chmod 777 /root/appnetdev-monitor.sh

    # 3 Recargar configuración de systemd, habilitar y iniciar el servicio
    sudo systemctl daemon-reload
    sudo systemctl enable appnetmonitor
    sudo systemctl start appnetmonitor

    # Reemplazar el valor del token en el seeder
    sed -i "s/\['token'\] =>.*/\['token'\] => '$TOKENHOST',/" database/seeders/HostListSeeder.php
    sudo apt -y install bc

    # Utilizar sed para reemplazar la línea que contiene DB_PASSWORD
    sed -i "s/^\(DB_DATABASE=\).*/\1${DB}/" "$ENV_FILE"
    sed -i "s/^\(DB_USERNAME=\).*/\1${NEW_USERNAME}/" "$ENV_FILE"
    sed -i "s/^\(DB_PASSWORD=\).*/\1${NEW_PASSWORD}/" "$ENV_FILE"
    sed -i "s/^\(APP_URL=\).*/\1http:\/\/${IP}\//" "$ENV_FILE"

    sed -i "s/^\(FTP_HOST=\).*/\1${FTP_HOST}/" "$ENV_FILE"
    sed -i "s/^\(FTP_USERNAME=\).*/\1${FTP_USER}/" "$ENV_FILE"
    sed -i "s/^\(FTP_PASSWORD=\).*/\1${FTP_PASSWORD}/" "$ENV_FILE"
    sed -i "s/^\(FTP_ROOT=\).*/\1$(echo "$FTP_ROOT" | sed 's/\//\\\//g')/" "$ENV_FILE"
    sed -i "s/^\(FTP_PASSIVE=\).*/\1${FTP_PASSIVE}/" "$ENV_FILE"
    sed -i "s/^\(FTP_THROW=\).*/\1${FTP_THROW}/" "$ENV_FILE"

    sed -i "s/^\(SFTP_HOST=\).*/\1${FTP_HOST}/" "$ENV_FILE"
    sed -i "s/^\(SFTP_USERNAME=\).*/\1${FTP_USER}/" "$ENV_FILE"
    sed -i "s/^\(SFTP_PASSWORD=\).*/\1${FTP_PASSWORD}/" "$ENV_FILE"
    sed -i "s/^\(SFTP_ROOT=\).*/\1$(echo "$FTP_ROOT" | sed 's/\//\\\//g')/" "$ENV_FILE"

    export COMPOSER_ALLOW_SUPERUSER=1
    /usr/local/bin/composer update
    echo 'generar con artisan todo lo de la base mysql necesario'
    /usr/bin/npm install -g vite
    php artisan key:generate
    php artisan migrate
    php artisan db:seed
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
    /usr/bin/npm run build
    echo 'dar los permisos necesario'
    cd storage || exit
    unzip logos.zip -d app
    cd /var/www/html/ || exit
    sudo rm -rf /var/www/html/public/storage
    sudo php artisan storage:link
    sudo chmod -R 777 /var/www
    sudo chmod -R 777 *
    sudo chmod -R 777 storage
    sudo chmod -R 777 app/Models
    sudo chmod 777 /var/www/html/storage/logs/
    sudo chmod 777 /var/www/html/storage/framework/sessions
    sudo chmod 777 /var/www/html/storage/framework/views

    sudo rm -rf .git

    sudo apt-get install -y supervisor
    sudo systemctl enable supervisor
    echo "Copiando archivos de configuración de Laravel a Supervisor..."
    CONFIG_SOURCE_DIR=$(pwd)
    CONFIG_DEST_DIR="/etc/supervisor/conf.d"

    for conf_file in $CONFIG_SOURCE_DIR/laravel*.conf; do
        if [ -f "$conf_file" ]; then
            sudo cp "$conf_file" "$CONFIG_DEST_DIR"
        fi
    done
    echo "Releyendo y actualizando configuración de Supervisor..."
    sudo supervisorctl reread
    sudo supervisorctl update
    echo "Iniciando y reiniciando servicios Laravel..."
    sudo supervisorctl start laravel*
    sudo supervisorctl restart laravel*
fi

sudo chown -R :nginx /var/www/html
sudo chown -R :www-data /var/www/html
sudo chmod -R g+rwx /var/www/html
sudo chown -R :nginx /var/www/html
sudo chmod -R g+rwx /var/www/html
sudo apt -y purge apache
sudo apt -y purge apache2
sudo apt -y autoremove

if [ "$DB" = "none" ]; then
    echo 'Sin anadir MariaDb '
elif [ "$DB" = "appnetd_cloud" ]; then
    echo 'MariaDb agregada con exito root password: '"$MARIADBPASSWORD"' donde el root tiene la opcion de remote host'
    # Mostrar usuario y contraseña generados
    echo "Nuevo usuario y contraseña generado para la ${DB}"
    echo "Usuario: ${NEW_USERNAME}"
    echo "Contraseña: ${NEW_PASSWORD}"
else
    echo "Por favor especifica none o una tabla de MariaDB en instalacion "
    exit 1
fi

echo "Contraseña FTP : $FTP_PASSWORD"
echo "Username FTP : $FTP_USER"
echo "Directorio FTP : $FTP_DIR"
echo "IP ZEROTIER : $IP"
echo "IP LOCAL : $IP"
