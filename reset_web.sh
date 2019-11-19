#!/bin/bash

#----------------------------------------------------------------------------------------------------------------
#                                                                                                            Info
#----------------------------------------------------------------------------------------------------------------
# name: UpdateNginx
# version: 2.0.0
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
FOLDER=


#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Funciones
#----------------------------------------------------------------------------------------------------------------
if (whiptail --title "Reinicio de la web" --yesno "Desea reiniciar los servicios web" 8 78); then
    {
                echo -e "XXX\n0\n Parando servicios... \nXXX"

                echo -e "XXX\n12\n Parando NGINX...\nXXX"
                        /etc/init.d/nginx stop &> /dev/null
                        sleep 0.1

                echo -e "XXX\n25\n  Parando PHP7...\nXXX"
                        /etc/init.d/php7.3-fpm stop &> /dev/null
                        sleep 0.1

                echo -e "XXX\n40\n  Parando MySQL...\nXXX"
                        /etc/init.d/mysql stop &> /dev/null
                        sleep 0.1

                echo -e "XXX\n55\n Limpiando caches... \nXXX"
                        rm $FOLDER/* -R &> /dev/null
                        rm $FOLDER/* -R &> /dev/null
                        rm -R /etc/nginx/cache/* &> /dev/null
                        sleep 0.1

                echo -e "XXX\n70\n  Iniciando MySQL...\nXXX"
                        /etc/init.d/mysql start &> /dev/null
                        sleep 0.1

                echo -e "XXX\n75\n  Iniciando PHP...\nXXX"
                        /etc/init.d/php7.3-fpm start &> /dev/null
                        sleep 0.1

                echo -e "XXX\n90\n  Iniciando NGINX...\nXXX"
                        /etc/init.d/nginx start &> /dev/null
                        sleep 0.1

                echo -e "XXX\n100\n Iniciando servicios...\nXXX"
                sleep 0.5

        } |whiptail --title "Reinicio de la web" --gauge "Please wait while installing" 6 60 0
else
        exit 1
fi
