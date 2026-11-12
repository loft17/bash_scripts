
#!/bin/bash

# Comprobacion especifica de vulnerabilidades Apache indicadas por INCIBE
# Solo lectura. No modifica configuraciones ni reinicia servicios.

set -u

echo "=========================================="
echo " COMPROBACION APACHE - AVISO INCIBE"
echo "=========================================="

# Detectar Apache
CTL=""

for cmd in apachectl apache2ctl httpd apache2; do
    if command -v "$cmd" >/dev/null 2>&1; then
        CTL=$(command -v "$cmd")
        break
    fi
done

if [ -z "$CTL" ]; then
    echo "[ERROR] Apache no encontrado."
    exit 1
fi

# Version Apache
APACHE_VERSION=$("$CTL" -v 2>/dev/null |
    sed -n 's/Server version: Apache\/\([0-9.]*\).*/\1/p')

if [ -z "$APACHE_VERSION" ]; then
    echo "[ERROR] No se puede obtener la version de Apache."
    exit 1
fi

# Modulos cargados
MODULES=$("$CTL" -M 2>&1)

# Comparacion de versiones
version_ge() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

version_le() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | tail -n1)" = "$2" ]
}

version_between() {
    version_ge "$1" "$2" && version_le "$1" "$3"
}

module_loaded() {
    echo "$MODULES" | grep -Eq "[[:space:]]${1}[[:space:]]"
}

echo
echo "Apache detectado: $APACHE_VERSION"
echo "Ejecutable: $CTL"
echo
echo "------------------------------------------"
echo "1. mod_http2"
echo "------------------------------------------"

if module_loaded "http2_module"; then
    echo "[CARGADO] mod_http2"

    if version_between "$APACHE_VERSION" "2.4.55" "2.4.70"; then
        echo "[VULNERABLE] Version dentro del rango afectado."
    else
        echo "[OK] Version fuera del rango indicado."
    fi
else
    echo "[NO CARGADO] mod_http2"
    echo "[OK] No aplica esta comprobacion."
fi

echo
echo "------------------------------------------"
echo "2. mod_h2 independiente"
echo "------------------------------------------"

H2_FILES=$(find /usr/lib /usr/lib64 /usr/local/lib \
    /etc/httpd /etc/apache2 \
    -type f -name 'mod_h2.so' 2>/dev/null)

if module_loaded "h2_module" || [ -n "$H2_FILES" ]; then
    echo "[DETECTADO] Posible mod_h2 independiente."

    H2_VERSION=""

    for file in $H2_FILES; do
        H2_VERSION=$(strings "$file" 2>/dev/null |
            grep -Eo '2\.0\.[0-9]+' | sort -Vu | tail -n1)
        [ -n "$H2_VERSION" ] && break
    done

    if [ -n "$H2_VERSION" ]; then
        echo "Version detectada: $H2_VERSION"

        if version_between "$H2_VERSION" "2.0.8" "2.0.42"; then
            echo "[VULNERABLE] Version dentro del rango afectado."
        else
            echo "[OK] Version fuera del rango indicado."
        fi
    else
        echo "[REVISAR] No se ha podido determinar la version."
        echo "Comprobar manualmente la version del mod_h2 independiente."
    fi
else
    echo "[NO DETECTADO] mod_h2 independiente."
    echo "[OK] No aplica esta comprobacion."
fi

echo
echo "------------------------------------------"
echo "3. mod_md"
echo "------------------------------------------"

if module_loaded "md_module"; then
    echo "[CARGADO] mod_md"

    if version_between "$APACHE_VERSION" "2.4.30" "2.4.70"; then
        echo "[VULNERABLE] Version dentro del rango afectado."
    else
        echo "[OK] Version fuera del rango indicado."
    fi
else
    echo "[NO CARGADO] mod_md"
    echo "[OK] No aplica esta comprobacion."
fi

echo
echo "------------------------------------------"
echo "4. mod_vhost_alias"
echo "------------------------------------------"

if module_loaded "vhost_alias_module"; then
    echo "[CARGADO] mod_vhost_alias"

    if [ "$APACHE_VERSION" = "2.4.69" ] ||
       [ "$APACHE_VERSION" = "2.4.70" ]; then
        echo "[VULNERABLE] Version dentro del rango afectado."
    else
        echo "[OK] Version fuera del rango indicado."
    fi
else
    echo "[NO CARGADO] mod_vhost_alias"
    echo "[OK] No aplica esta comprobacion."
fi

echo
echo "=========================================="
echo " FIN DE COMPROBACION"
echo "=========================================="
echo
echo "NOTA: Comprobacion basada en versiones y modulos cargados."
echo "En distribuciones Linux pueden existir parches retroportados."
