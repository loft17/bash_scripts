#!/bin/bash

#----------------------------------------------------------------------------------------------------------------
#                                                                                                            Info
#----------------------------------------------------------------------------------------------------------------
# name: GitTravel
# version:
# autor: joseRomera <web@joseromera.net>
# web: http://www.joseromera.net
# Copyright (C) 2020
#----------------------------------------------------------------------------------------------------------------


#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Variables
#----------------------------------------------------------------------------------------------------------------

DATE=$(date +"%Y%m%d_%H%M%S")
REPOSITORIO="XXXX"
FOLDER="XXXX"
FOLDERWEB="XXXX"
FOLDERTMP="tmp"
FOLDERBCK="bck"

USER="XXXX"
PASS="XXXX"
# Si la contraseñan tiene caracteres especiales, no funcionara.
# https://support.brightcove.com/special-characters-usernames-and-passwords

#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Funciones
#----------------------------------------------------------------------------------------------------------------

cd $FOLDER
mkdir $FOLDERBCK
git clone https://$USER:$PASS@$REPOSITORIO $FOLDERTMP
mv $FOLDER/$FOLDERWEB $FOLDER/$FOLDERBCK/$FOLDERWEB_$DATE
mv $FOLDER/$FOLDERTMP $FOLDER/$FOLDERWEB

