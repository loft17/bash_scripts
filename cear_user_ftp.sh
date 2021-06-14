#!/bin/sh

if  [ $1 = "-n" ]; then
    echo "Creamos el usuario"
    # Creamos la carpeta del usuario
    mkdir /var/srv/ftp/$2
    # Cambiamos los permisos de la carpeta
    chown 60:60 /var/srv/ftp/$2
    # Creamos el usuario
    ftpasswd --passwd --file=/etc/proftpd/ftpd.passwd --name=$2 --uid=60 --gid=60 --home=/srv/ftp/$2 --shell=/bin/false
    # Agregamos el usuario al gruoi
    ftpasswd --group --name=nogroup --file=/etc/proftpd/ftpd.group --gid=60 --member $2
elif [ $1 = "-c" ]; then
    echo "Cambiamos la pass"
    ftpasswd --passwd --file=/etc/proftpd/ftpd.passwd --name=$2 --change-password
elif [ $1 = "-d" ]; then
    echo "eliminamos"
    ftpasswd --passwd --file=/etc/proftpd/ftpd.passwd --name=$2 --delete-user
    # Eliminamos la carpeta
    rm -rf mkdir /var/srv/ftp/$2
elif [ $1 = "-l" ]; then
    echo "bloqueamos el usuario"
    ftpasswd --passwd --file=/etc/proftpd/ftpd.passwd --name=$2 --lock
elif [ $1 = "-u" ]; then
    echo "desbloqueamos el usuario"
    ftpasswd --passwd --file=/etc/proftpd/ftpd.passwd --name=$2 --unlock
else
    echo ""
    echo "Usage: ./crear_user_ftp.sh [options] [USER]"
    echo ""
    echo "Options:"
    echo "  -n                  Crear usuario nuevo"
    echo "  -c                  Cambiar password de usuario"
    echo "  -d                  Eliminar un usuario"
    echo "  -l                  Bloquear usuario"
    echo "  -u                  Desbloquear usuario"
    echo ""
fi
