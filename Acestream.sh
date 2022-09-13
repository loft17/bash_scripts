#!/bin/bash

##################################################################################################################
#                                                                                                        Variables
##################################################################################################################
# Variables fecha
ANNOACTUAL=$(date +%Y)

DATE=$(date +"%Y%m%d")
FECHAHOY=$(date +"%d%m%Y")


# Variables Carpetas
FOLDER_TMP="/home/joseluis/acestream/tmp"
FOLDER_HTMLTEMP="/home/joseluis/acestream/templatehtml"


#setup colors
cyan='\e[0;36m'
green='\033[92m'
red='\e[1;31m'
yellow='\e[0;33m'
orange='\e[38;5;166m'
black='\e[0;30m'
NoColor='\033[0m' # No Color



##################################################################################################################
#                                                                                                        FUNCIONES
##################################################################################################################
CarpetaTemporal(){
    rm -r $FOLDER_TMP
    mkdir -p $FOLDER_TMP
}



# ----------------------------------------------------------------------------------------------------------------
# Construir Web
# ----------------------------------------------------------------------------------------------------------------
CreateHTML(){
    cat $FOLDER_HTMLTEMP/head.tmp >> $FOLDER_TMP/index.tmp



    ls -1 $FOLDER_TMP | grep id > $FOLDER_TMP/listWEB.tmp

    cat $FOLDER_TMP/listWEB.tmp | while read LINE1; do
        cat $FOLDER_TMP/$LINE1 | while read LINEA2; do
            CANAL_NAME=$(echo $LINEA2 | awk 'BEGIN { FS = ";" } ; { print $1 }')
            CANAL_ID=$(echo $LINEA2 | awk 'BEGIN { FS = ";" } ; { print $2 }')


            echo "<tr>" >> $FOLDER_TMP/html_$LINE1
            echo "<th scope="row">1</th>" >> $FOLDER_TMP/html_$LINE1
            echo "<td>$CANAL_NAME</td>" >> $FOLDER_TMP/html_$LINE1
            echo "<td><a href="acestream:$CANAL_ID">$CANAL_ID</a></td>" >> $FOLDER_TMP/html_$LINE1
            echo "</tr>" >> $FOLDER_TMP/html_$LINE1


        done
        cat $FOLDER_TMP/html_$LINE1 >> $FOLDER_TMP/index.tmp

    done

    cat $FOLDER_HTMLTEMP/footer.tmp >> $FOLDER_TMP/index.tmp
    cp $FOLDER_TMP/index.tmp /var/www/html/index.html

}




# ----------------------------------------------------------------------------------------------------------------
# https://acestreamid.com/
# ----------------------------------------------------------------------------------------------------------------
ACESTREAMID(){
    # Descargamos la web
    #wget -q -U mozilla -O $FOLDER_TMP/ACESTREAMID.html https://acestreamid.com/

    # Nos quedamos con la info que queremos con el id acestream y el canal
    cat $FOLDER_TMP/ACESTREAMID.html | grep "acestream://" -B 4 >> $FOLDER_TMP/WEB_A001.tmp
    # Quitamos info/datos innecesarios
    sed -i '/div/d' $FOLDER_TMP/ACESTREAMID.tmp
    sed -i '/li/d' $FOLDER_TMP/ACESTREAMID.tmp
    sed -i '/ul/d' $FOLDER_TMP/ACESTREAMID.tmp
    sed -i '/channel/d' $FOLDER_TMP/ACESTREAMID.tmp

    VAR=1
    cat $FOLDER_TMP/ACESTREAMID.tmp | while read LINEA; do

        if [[ $LINEA != '--' ]]; then
            if [[ $VAR -eq "1" ]]; then
                CANAL=`echo $LINEA | awk -F " <" '{print $1}'`
                VAR=$[$VAR+1]
            else
                ACEID=`echo $LINEA | awk -F " " '{print $2}' | awk -F "//" '{print $2}' | sed 's/">//g'`
                echo $CANAL";"$ACEID >> $FOLDER_TMP/ACESTREAMID-id.tmp
            fi
        else
            VAR=1
        fi

    done
}



# ----------------------------------------------------------------------------------------------------------------
# https://acestreamid.com/channel/movistar-futbol-hd-es
# ----------------------------------------------------------------------------------------------------------------
MOVISTAR_A1(){
    # Descargamos la web
    #wget -q -U mozilla -O $FOLDER_TMP/MOVISTAR_A1.html https://acestreamid.com/channel/movistar-futbol-hd-es?full
    wget -q -U mozilla -O $FOLDER_TMP/MOVISTAR_A1.html https://acestreamid.com/channel/movistar-futbol-hd-es

    # Nos quedamos con la info que queremos con el id acestream y el canal
    cat $FOLDER_TMP/MOVISTAR_A1.html | grep "acestream://" -B 4 >> $FOLDER_TMP/MOVISTAR_A1.tmp
    # Quitamos info/datos innecesarios
    sed -i '/div/d' $FOLDER_TMP/MOVISTAR_A1.tmp
    sed -i '/li/d' $FOLDER_TMP/MOVISTAR_A1.tmp
    sed -i '/ul/d' $FOLDER_TMP/MOVISTAR_A1.tmp
    sed -i '/channel/d' $FOLDER_TMP/MOVISTAR_A1.tmp

    VAR=1
    cat $FOLDER_TMP/MOVISTAR_A1.tmp | while read LINEA; do

        if [[ $LINEA != '--' ]]; then
            if [[ $VAR -eq "1" ]]; then
                CANAL=`echo $LINEA | awk -F " <" '{print $1}'`
                VAR=$[$VAR+1]
            else
                ACEID=`echo $LINEA | awk -F " " '{print $2}' | awk -F "//" '{print $2}' | sed 's/">//g'`
                echo $CANAL";"$ACEID >> $FOLDER_TMP/MOVISTAR_A1-id.tmp
            fi
        else
            VAR=1
        fi

    done
}


# ----------------------------------------------------------------------------------------------------------------
# https://acestreamid.com/channel/movistar-futbol
# ----------------------------------------------------------------------------------------------------------------
MOVISTAR_A2(){
    # Descargamos la web
    #wget -q -U mozilla -O $FOLDER_TMP/MOVISTAR_A2.html https://acestreamid.com/channel/movistar-futbol?full

    # Nos quedamos con la info que queremos con el id acestream y el canal
    cat $FOLDER_TMP/MOVISTAR_A2.html | grep "acestream://" -B 4 >> $FOLDER_TMP/MOVISTAR_A2.tmp
    # Quitamos info/datos innecesarios
    sed -i '/div/d' $FOLDER_TMP/MOVISTAR_A2.tmp
    sed -i '/li/d' $FOLDER_TMP/MOVISTAR_A2.tmp
    sed -i '/ul/d' $FOLDER_TMP/MOVISTAR_A2.tmp
    sed -i '/channel/d' $FOLDER_TMP/MOVISTAR_A2.tmp

    VAR=1
    cat $FOLDER_TMP/MOVISTAR_A2.tmp | while read LINEA; do

        if [[ $LINEA != '--' ]]; then
            if [[ $VAR -eq "1" ]]; then
                CANAL=`echo $LINEA | awk -F " <" '{print $1}'`
                VAR=$[$VAR+1]
            else
                ACEID=`echo $LINEA | awk -F " " '{print $2}' | awk -F "//" '{print $2}' | sed 's/">//g'`
                echo $CANAL";"$ACEID >> $FOLDER_TMP/MOVISTAR_A2-id.tmp
            fi
        else
            VAR=1
        fi

    done
}





# ----------------------------------------------------------------------------------------------------------------
# https://acestreamid.com/channel/movistar-futbol-hd-es
# ----------------------------------------------------------------------------------------------------------------
TEST(){
    # Descargamos la web
    #wget -q -U mozilla -O $FOLDER_TMP/MOVISTAR_A1.html https://acestreamid.com/channel/movistar-futbol-hd-es

    #VAR=1
    #cat $FOLDER_TMP/MOVISTAR_A1.tmp | while read LINEA; do
    #
    #    if [[ $LINEA != '--' ]]; then
    #        if [[ $VAR -eq "1" ]]; then
    #            CANAL=`echo $LINEA | awk -F " <" '{print $1}'`
    #            VAR=$[$VAR+1]
    #        else
    #            ACEID=`echo $LINEA | awk -F " " '{print $2}' | awk -F "//" '{print $2}' | sed 's/">//g'`
    #            echo $CANAL";"$ACEID >> $FOLDER_TMP/MOVISTAR_A1-id.tmp
    #        fi
    #    else
    #        VAR=1
    #    fi
    #done

    # Nos quedamos con la info que queremos con el id acestream y el canal
    cat $FOLDER_TMP/MOVISTAR_A1.html | grep "acestream://" -B 4 -A 18 >> $FOLDER_TMP/MOVISTAR_A1.tmp
    # Quitamos info/datos innecesarios
    sed -i '/div/d' $FOLDER_TMP/MOVISTAR_A1.tmp
    sed -i '/<a href="#">/d' $FOLDER_TMP/MOVISTAR_A1.tmp
    sed -i '/timeago/d' $FOLDER_TMP/MOVISTAR_A1.tmp
    sed -i '/fa-thumbs-up/d' $FOLDER_TMP/MOVISTAR_A1.tmp
    sed -i '/fa-thumbs-down/d' $FOLDER_TMP/MOVISTAR_A1.tmp
}



##################################################################################################################
#                                                                                                        FUNCIONES
##################################################################################################################
CarpetaTemporal
MOVISTAR_A1
