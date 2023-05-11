#!/bin/bash

#-----------------------------------------------------------------------------------------------------------------
#                                                                                                            Info
#-----------------------------------------------------------------------------------------------------------------
#
# name: backupserver
# version: 4.0.0-Beta
# autor: joseRomera <web@joseromera.net>
# web: http://www.joseromera.net
# Copyright (C) 2016-2023
#
#-----------------------------------------------------------------------------------------------------------------
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
#
#-----------------------------------------------------------------------------------------------------------------


#-----------------------------------------------------------------------------------------------------------------
#                                                                                                       Variables
#-----------------------------------------------------------------------------------------------------------------
# Variables fecha
DATE=$(date +"%Y%m%d")

# Variables carpetas
PATH_TMP=/tmp/bcktmp                        # carpeta backup
PATH_NGX=/etc/nginx                         # carpeta nginx
PATH_SCR=/root/scripts                      # carpeta scripts joseluis
PATH_HTTP=/srv/http                         # caperta http
PATH_BCK=/root/backups

# Variables password
PASS7ZP="-_v8m1vAW7rsEUZK6vAX"
SQLPASS="0AgEkw@TBP.2Aj(K^5"
SQLUSER="root"


#-----------------------------------------------------------------------------------------------------------------
#                                                                                                       Funciones
#-----------------------------------------------------------------------------------------------------------------
# Eliminamos temporales
deletefoldertmp(){
    rm -R $PATH_TMP 2> /dev/null
    #date +%A
    # Creamos la carpeta temporal
    mkdir $PATH_TMP/server_$DATE -p
}


# Bck Scripts / fail2ban
backupfilessystem(){
    cp -R $PATH_SCR $PATH_TMP/server_$DATE
    cp /etc/fail2ban/jail.local $PATH_TMP/server_$DATE
    cp /etc/hosts.allow $PATH_TMP/server_$DATE
    cp /etc/fail2ban/filter.d/wordpress.conf $PATH_TMP/server_$DATE
}

backupnginxfolder(){
    cp -R $PATH_NGX $PATH_TMP/server_$DATE
}

backupfolderwebs(){
    FOLDERSWEBS=`ls $PATH_HTTP | grep -v /`;
    for FOLDERWEB in ${FOLDERSWEBS}; do
        mkdir -p $PATH_TMP/server_$DATE/$FOLDERWEB
        cp -R $PATH_HTTP/$FOLDERWEB/public_html $PATH_TMP/server_$DATE/$FOLDERWEB 2> /dev/null
        cp -R $PATH_HTTP/$FOLDERWEB/ssl $PATH_TMP/server_$DATE/$FOLDERWEB 2> /dev/null
    done
}

backupfolderzip(){
    7z a -p$PASS7ZP -mx=9 -mhe -t7z $PATH_BCK/server_$DATE.7z $PATH_TMP/*
}

backupBBDD(){
    #  mysql -u root -p -Bse "SHOW DATABASES LIKE '%_db';"
    SHOWDDBB=`mysql --user=$SQLUSER --password=$SQLPASS -Bse "SHOW DATABASES LIKE '%_db';"`;
    for NAMEDDBB in ${SHOWDDBB}; do
        mysqldump --user=$SQLUSER --password=$SQLPASS $NAMEDDBB > $PATH_TMP/server_$DATE/$NAMEDDBB.sql
    done
}

backupwebs(){
    if [ $(date +%A) = "jueves" ]
        then
            # Copiamos las webs que tengamos:
            backupfolderwebs
            # Copiamos las BBDD
            backupBBDD
            # Comprimimos y encriptamos los ficheros
            backupfolderzip
            # Copiamos el backup en GLACE
            mv $PATH_BCK/server_$DATE.7z $PATH_BCK/semanal
	        
        else
            backupBBDD
            backupfolderzip
            mv $PATH_BCK/server_$DATE.7z $PATH_BCK/diaria

    fi
                
}


deletebackupsolds(){
    # Eliminamos copias con mas de 180 días
    find $PATH_BCK/semanal/server_* -mtime +180 -exec rm {} \; 2> /dev/null
    find $PATH_BCK/diaria/server_* -mtime +180 -exec rm {} \; 2> /dev/null
}


#-----------------------------------------------------------------------------------------------------------------
#                                                                                                        EJECUCION
#-----------------------------------------------------------------------------------------------------------------
deletefoldertmp
backupfilessystem
backupwebs
deletefoldertmp
deletebackupsolds
