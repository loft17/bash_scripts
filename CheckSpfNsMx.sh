!/bin/bash

#----------------------------------------------------------------------------------------------------------------
#                                                                                                            Info
#----------------------------------------------------------------------------------------------------------------
# name: CheckSpfNsMx
# version: 20221201.01
# autor: Jose Luis Romera
#----------------------------------------------------------------------------------------------------------------

rm /root/checkspf/listado.cvs

cat /root/checkspf/listado | while read DOMAIN; do
        SHOWSPF=`dig TXT $DOMAIN | grep "spf" | awk -F '"' '{print $2}'`
        SHOWNS=`dig NS $DOMAIN | sed '/;/d' | sed '/^$/d' | sed -n '1p' | awk -F ' ' '{print $5}'`
        SHOWMX=`dig MX $DOMAIN | sed '/;/d' | sed '/^$/d' | sed -n '1p' | awk -F ' ' '{print $5,$6}'`

        echo $DOMAIN
        echo "$DOMAIN;$SHOWSPF;$SHOWNS;$SHOWMX" >> /root/checkspf/listado.cvs
done
