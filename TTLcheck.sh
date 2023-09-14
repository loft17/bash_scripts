#!/bin/bash

#----------------------------------------------------------------------------------------------------------------
#                                                                                                            Info
#----------------------------------------------------------------------------------------------------------------
# name: TTLcheck
# version: 20230914
# autor: Jose Luis Romera
#----------------------------------------------------------------------------------------------------------------
#setup colors
green='\033[92m'
red='\e[1;31m'
NoColor='\033[0m'
TTL=1024

if [ -z $1 ]; then
    echo "Por favor. Añada un dominio o ip al comando"
else
    TTL=`ping -w 2 -c 1 $1 | grep "ttl" | awk '{print $6}' | awk -F"=" '{print $2}'`

    if [ $TTL -le 64 ] 2>/dev/null; then
        echo -n -e "$1 (ttl => $TTL):" $green"Es un Linux"$NoColor
    elif [ $TTL -le 128 ] 2>/dev/null; then
        echo -n -e "$1 (ttl => $TTL):" $green"Es un Windows"$NoColor
    else
        echo -n -e $1 $red"host no encontrado"$NoColor
    fi
fi
