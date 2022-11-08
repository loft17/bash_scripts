#!/bin/bash

#----------------------------------------------------------------------------------------------------------------
#                                                                                                            Info
#----------------------------------------------------------------------------------------------------------------
# name: UpdateNginx
# version: 0.1.0
# autor: joseRomera <web@joseromera.net>
# web: http://www.joseromera.net
# Copyright (C) 2016-2018
#----------------------------------------------------------------------------------------------------------------
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#----------------------------------------------------------------------------------------------------------------


#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Variables
#----------------------------------------------------------------------------------------------------------------
NGINXOLD=1.15.7
OPENSSLOLD=1.1.1a



#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Funciones
#----------------------------------------------------------------------------------------------------------------
if (whiptail --title "Actualizar NGINX" --yesno "Desea actualizar Nginx." 8 78); then
	# SI ACEPTA ---------------
   
	# VERSION NGINX
	NGINXNEW=$(whiptail --inputbox "Que version quiere instalar?" 8 78 $NGINXOLD --title "Actualizar NGINX" 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		echo "User selected Ok and entered " $NGINXNEW
	else
		exit 1
	fi

	# VERSION OpenSSL
	OPENSSLV=$(whiptail --inputbox "Que version quiere instalar?" 8 78 $OPENSSLOLD --title "Actualizar NGINX" 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		echo "User selected Ok and entered " $OPENSSLV
	else
		exit 1
	fi
	
	{

		sleep 0.5
	
		echo -e "XXX\n0\n Eliminando carpetas antiguas... \nXXX"
			rm /tmp/* -R
			echo -e "XXX\n5\n Eliminando carpetas antiguas... Done.\nXXX"
		sleep 0.5

		echo -e "XXX\n5\n Creando carpetas... \nXXX"
			mkdir /tmp/nginx && cd /tmp/nginx
		echo -e "XXX\n10\n Creando carpetas... Done.\nXXX"
		sleep 0.5

		# OpenSSL
		echo -e "XXX\n10\n OpenSSL... \nXXX"
			wget https://www.openssl.org/source/openssl-$OPENSSLV.tar.gz &> /dev/null 
			tar -xzvf openssl-$OPENSSLV.tar.gz &> /dev/null
		echo -e "XXX\n20\n OpenSSL... Done.\nXXX"
		sleep 0.5

		# Page Speed 
		echo -e "XXX\n20\n PAGESPEED NGX... \nXXX"
			wget https://github.com/pagespeed/ngx_pagespeed/archive/v1.12.34.3-stable.zip &> /dev/null 
			unzip v1.12.34.3-stable.zip &> /dev/null
			cd incubator-pagespeed-ngx-1.12.34.3-stable/ &> /dev/null
		echo -e "XXX\n30\n PAGESPEED PSOL... Done.\nXXX"
		sleep 0.5
	
		echo -e "XXX\n30\n PAGESPEED NGX... \nXXX"
			wget https://dl.google.com/dl/page-speed/psol/1.12.34.2-x64.tar.gz &> /dev/null
			tar -xzvf 1.12.34.2-x64.tar.gz &> /dev/null
			cd .. &> /dev/null
		echo -e "XXX\n40\n PAGESPEED PSOL... Done.\nXXX"
		sleep 0.5

		# Modulos NGINX
		echo -e "XXX\n40\n MODULOS NGINX... \nXXX"
			wget https://github.com/openresty/headers-more-nginx-module/archive/master.zip -O headers.zip &> /dev/null
			unzip headers.zip &> /dev/null
		echo -e "XXX\n50\n Modulo Headers More... Done.\nXXX"
		sleep 0.5

		echo -e "XXX\n50\n MODULOS NGINX... \nXXX"
			wget https://github.com/nbs-system/naxsi/archive/master.zip -O naxsi.zip &> /dev/null
			unzip naxsi.zip &> /dev/null
		echo -e "XXX\n60\n Modulo NAXSI... Done.\nXXX"
		sleep 0.5

		# NGINX
		echo -e "XXX\n60\n NGINX Download... \nXXX"
			wget https://nginx.org/download/nginx-$NGINXNEW.tar.gz &> /dev/null
			tar -xvzf nginx-$NGINXNEW.tar.gz &> /dev/null
			cd nginx-$NGINXNEW &> /dev/null
		echo -e "XXX\n70\n NGINX Download... Done.\nXXX"
		sleep 0.5

		# Precompilar NGINX
		echo -e "XXX\n70\n Precompilando NGINX.... \nXXX"
			./configure --add-module=/tmp/nginx/naxsi-master/naxsi_src \
			--add-module=/tmp/nginx/incubator-pagespeed-ngx-1.12.34.3-stable/ \
			--add-module=/tmp/nginx/headers-more-nginx-module-master/ \
			--prefix=/usr/share/nginx \
			--sbin-path=/usr/sbin/nginx \
			--conf-path=/etc/nginx/nginx.conf \
			--pid-path=/var/run/nginx.pid \
			--lock-path=/var/lock/nginx.lock \
			--error-log-path=/var/log/nginx/error.log \
			--http-log-path=/var/log/nginx/access.log \
			--user=www-data \
			--group=www-data \
			--without-mail_pop3_module \
			--without-mail_imap_module \
			--without-mail_smtp_module \
			--with-http_stub_status_module \
			--with-http_mp4_module \
			--with-stream \
			--with-stream_ssl_module \
			--with-cpp_test_module \
			--with-http_gunzip_module \
			--with-http_auth_request_module \
			--with-http_secure_link_module \
			--with-http_v2_module \
			--with-http_gzip_static_module \
			--with-http_geoip_module \
			--http-client-body-temp-path=/var/lib/nginx/body \
			--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
			--http-proxy-temp-path=/var/lib/nginx/proxy \
			--http-scgi-temp-path=/var/lib/nginx/scgi \
			--http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
			--with-http_ssl_module \
			--with-openssl=/tmp/nginx/openssl-$OPENSSLV \
			--with-http_random_index_module \
			--with-mail \
			--with-pcre \
			--with-http_realip_module &> /dev/null
		echo -e "XXX\n80\n Precompilando NGINX... Done.\nXXX"
		sleep 0.5

		# Compilamos NGINX
		echo -e "XXX\n80\n Compilar NGINX... \nXXX"
			make &> /dev/null
		echo -e "XXX\n90\n Compilar NGINX... Done.\nXXX"
		sleep 0.5

		# Instalar NGINX
		echo -e "XXX\n90\n Instalar NGINX... \nXXX"
			make install &> /dev/null
		echo -e "XXX\n100\n Instalar NGINX... Done.\nXXX"
		sleep 0.5

	} |whiptail --title "Actualizar NGINX" --gauge "Please wait while installing" 6 60 0
	
	# REINICIO
	if (whiptail --title "Actualizar NGINX" --yesno "Desea Reiciar el equipo." 8 78); then
		# SI ACEPTA -----
		reboot
	else
		#SI NO ACEPTA -----
		exit 1
	fi	
	
else
	#SI NO ACEPTA -----
    echo "CANCEL."
fi
