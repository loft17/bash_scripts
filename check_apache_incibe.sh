
#!/bin/bash

# Comprobacion Apache - Vulnerabilidades INCIBE
# Solo lectura

# Colores
if [ -t 1 ] && [ "${NO_COLOR:-}" = "" ]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    GREEN=''
    RED=''
    YELLOW=''
    BLUE=''
    NC=''
fi

ok() {
    echo -e "${GREEN}[OK] $1${NC}"
}

vuln() {
    echo -e "${RED}[VULNERABLE] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[REVISAR] $1${NC}"
}

info() {
    echo -e "${BLUE}$1${NC}"
}

echo
info "=========================================="
info " COMPROBACION APACHE - AVISO INCIBE"
info "=========================================="

CTL=""

for cmd in apachectl apache2ctl httpd apache2; do
    if command -v "$cmd" >/dev/null 2>&1; then
        CTL=$(command -v "$cmd")
        break
    fi
done

if [ -z "$CTL" ]; then
    vuln "Apache no encontrado."
    exit 1
fi

APACHE_VERSION=$("$CTL" -v 2>/dev/null |
    sed -n 's/Server version: Apache\/\([0-9.]*\).*/\1/p')

if [ -z "$APACHE_VERSION" ]; then
    warn "No se puede obtener la version de Apache."
    exit 1
fi

MODULES=$("$CTL" -M 2>&1)

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
info "------------------------------------------"
info "1. mod_http2"
info "------------------------------------------"

if module_loaded "http2_module"; then
    echo "Modulo: mod_http2"

    if version_between "$APACHE_VERSION" "2.4.55" "2.4.70"; then
        vuln "Apache $APACHE_VERSION con mod_http2."
    else
        ok "Apache $APACHE_VERSION fuera del rango indicado."
    fi
else
    ok "mod_http2 no esta cargado."
fi

echo
info "------------------------------------------"
info "2. mod_h2 independiente"
info "------------------------------------------"

H2_FILES=$(find /usr/lib /usr/lib64 /usr/local/lib \
    /etc/httpd /etc/apache2 \
    -type f -name 'mod_h2.so' 2>/dev/null)

if [ -n "$H2_FILES" ]; then
    H2_VERSION=""

    while IFS= read -r file; do
        H2_VERSION=$(strings "$file" 2>/dev/null |
            grep -Eo '2\.0\.[0-9]+' | sort -Vu | tail -n1)
        [ -n "$H2_VERSION" ] && break
    done <<< "$H2_FILES"

    if [ -n "$H2_VERSION" ]; then
        echo "Version detectada: $H2_VERSION"

        if version_between "$H2_VERSION" "2.0.8" "2.0.42"; then
            vuln "mod_h2 independiente version $H2_VERSION."
        else
            ok "mod_h2 version fuera del rango indicado."
        fi
    else
        warn "mod_h2 encontrado, pero no se pudo determinar su version."
    fi
else
    ok "No se ha encontrado mod_h2 independiente."
fi

echo
info "------------------------------------------"
info "3. mod_md"
info "------------------------------------------"

if module_loaded "md_module"; then
    echo "Modulo: mod_md"

    if version_between "$APACHE_VERSION" "2.4.30" "2.4.70"; then
        vuln "Apache $APACHE_VERSION con mod_md."
    else
        ok "Apache $APACHE_VERSION fuera del rango indicado."
    fi
else
    ok "mod_md no esta cargado."
fi

echo
info "------------------------------------------"
info "4. mod_vhost_alias"
info "------------------------------------------"

if module_loaded "vhost_alias_module"; then
    echo "Modulo: mod_vhost_alias"

    if [ "$APACHE_VERSION" = "2.4.69" ] ||
       [ "$APACHE_VERSION" = "2.4.70" ]; then
        vuln "Apache $APACHE_VERSION con mod_vhost_alias."
    else
        ok "Apache $APACHE_VERSION fuera del rango indicado."
    fi
else
    ok "mod_vhost_alias no esta cargado."
fi

echo
info "=========================================="
info " FIN DE COMPROBACION"
info "=========================================="
echo
warn "La version no determina por si sola si hay parches retroportados."
