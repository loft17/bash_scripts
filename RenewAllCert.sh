#!/bin/bash
##################################################################################################################
#                                                                                                        Variables
##################################################################################################################
#setup colors
cyan='\e[0;36m'
green='\033[92m'
red='\e[1;31m'
yellow='\e[0;33m'
orange='\e[38;5;166m'
black='\e[0;30m'
NoColor='\033[0m' # No Color

EMAIL=""

##################################################################################################################
#                                                                                                        FUNCIONES
##################################################################################################################

CreateCert(){
        service nginx stop
        certbot certonly --standalone $DOMINIO --rsa-key-size 4096 --rsa-key-size 4096 -m $EMAIL --agree-tos
        rm -rf /srv/http/$DOMINIOFOLDER/ssl/*
        cp /etc/letsencrypt/live/$DOMINIOFOLDER/cert.pem        /srv/http/$DOMINIOFOLDER/ssl/
        cp /etc/letsencrypt/live/$DOMINIOFOLDER/chain.pem       /srv/http/$DOMINIOFOLDER/ssl/
        cp /etc/letsencrypt/live/$DOMINIOFOLDER/fullchain.pem   /srv/http/$DOMINIOFOLDER/ssl/
        cp /etc/letsencrypt/live/$DOMINIOFOLDER/privkey.pem     /srv/http/$DOMINIOFOLDER/ssl/
        service nginx start
}


DominioWWWes(){
        DOMINIO="-d xxx.es -d www.xxx.es"
        DOMINIOFOLDER="www.joseromera.es"
        CreateCert
}


##################################################################################################################
menu(){
        echo -e "$green""Seleccione una de las opciones" "$NoColor" ""
        echo "1) ------------------                      2) ------------------"
        echo "3) ------------------                      4) ------------------"
        echo "0) Exit"

    read a
    case $a in
        1) DominioWWWes ; menu ;;
        2) DominioWWWnet ; menu ;;
        3) DominioWWWcat ; menu ;;
        0) exit 0 ;;
        *) echo -e $red"Wrong option."$clear; WrongCommand;;
        esac
}


##################################################################################################################
#                                                                                                             MENU
##################################################################################################################
menu

