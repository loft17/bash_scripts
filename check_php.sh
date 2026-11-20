#!/usr/bin/env bash
# check_php.sh - Comprueba si el sistema está expuesto a las vulnerabilidades de PHP
# del aviso de INCIBE-CERT (múltiples vulnerabilidades en PHP).
#
# Uso: ./check_php.sh
# Salida: 0 = sin problemas detectados, 1 = hay problemas o avisos que revisar.
#
# IMPORTANTE: rellena FIXED_VERSIONS con las versiones corregidas indicadas en el
# aviso oficial (una por rama, formato "rama=versión_corregida").
# Ejemplo: FIXED_VERSIONS=("8.2=8.2.X" "8.3=8.3.Y")  (sustituye X e Y por los valores reales)

set -u

#FIXED_VERSIONS=()   # <-- rellenar con los datos del aviso
FIXED_VERSIONS=("8.1=8.1.X" "8.2=8.2.Y" "8.3=8.3.Z")

ISSUES=0
WARNINGS=0

ok()   { printf '[ OK ]  %s\n' "$*"; }
warn() { printf '[WARN]  %s\n' "$*"; WARNINGS=$((WARNINGS+1)); }
bad()  { printf '[FAIL]  %s\n' "$*"; ISSUES=$((ISSUES+1)); }
info() { printf '[INFO]  %s\n' "$*"; }

echo "=== Comprobación de PHP ==="

# 1. Binario de PHP CLI
if ! command -v php >/dev/null 2>&1; then
    info "No se encuentra el binario 'php' en el PATH."
    echo "Si usas PHP solo para Apache/Nginx, comprueba también la versión de tu SAPI."
else
    PHP_VERSION=$(php -r 'echo PHP_VERSION;' 2>/dev/null)
    PHP_BRANCH=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;' 2>/dev/null)
    info "Versión de PHP CLI: ${PHP_VERSION}"

    # 2. Comparación con la versión corregida de la rama instalada
    if [ "${#FIXED_VERSIONS[@]}" -eq 0 ]; then
        warn "FIXED_VERSIONS está vacío: no se puede comparar con el aviso. Rellénalo en el script."
    else
        matched=0
        for entry in "${FIXED_VERSIONS[@]}"; do
            branch="${entry%%=*}"
            fixed="${entry#*=}"
            if [ "$branch" = "$PHP_BRANCH" ]; then
                matched=1
                lowest=$(printf '%s\n%s\n' "$PHP_VERSION" "$fixed" | sort -V | head -n1)
                if [ "$lowest" = "$fixed" ] || [ "$PHP_VERSION" = "$fixed" ]; then
                    ok "PHP ${PHP_VERSION} es igual o superior a la versión corregida (${fixed})."
                else
                    bad "PHP ${PHP_VERSION} es anterior a la versión corregida ${fixed} (rama ${branch})."
                fi
            fi
        done
        if [ "$matched" -eq 0 ]; then
            warn "No hay versión corregida definida para la rama ${PHP_BRANCH}. Revisa el aviso."
        fi
    fi

    # 3. Configuración potencialmente insegura
    expose=$(php -r 'echo ini_get("expose_php");' 2>/dev/null)
    display=$(php -r 'echo ini_get("display_errors");' 2>/dev/null)
    inc_url=$(php -r 'echo ini_get("allow_url_include");' 2>/dev/null)
    [ "$expose" = "1" ] || [ "$expose" = "On" ] && warn "expose_php=On: revela la versión de PHP en las cabeceras HTTP."
    [ "$display" = "1" ] || [ "$display" = "On" ] && warn "display_errors=On: no conviene en producción."
    [ "$inc_url" = "1" ] || [ "$inc_url" = "On" ] && bad "allow_url_include=On: riesgo alto de ejecución remota de código."
    [ "$inc_url" != "1" ] && [ "$inc_url" != "On" ] && ok "allow_url_include desactivado."
fi

echo
echo "=== Procesos PHP en ejecución ==="
if pgrep -a 'php-fpm|php-cgi' >/dev/null 2>&1; then
    pgrep -a 'php-fpm|php-cgi' | head -n5
    info "Recuerda reiniciar php-fpm/Apache/Nginx tras actualizar PHP."
else
    info "No hay php-fpm/php-cgi en ejecución."
fi
if pgrep -x apache2 >/dev/null 2>&1 || pgrep -x httpd >/dev/null 2>&1; then
    if apache2ctl -M 2>/dev/null | grep -q php || httpd -M 2>/dev/null | grep -q php; then
        warn "Apache tiene cargado un módulo PHP (mod_php): reinicia Apache tras la actualización."
    fi
fi

echo
echo "=== Actualizaciones pendientes de paquetes PHP ==="
if command -v apt >/dev/null 2>&1; then
    pending=$(apt list --upgradable 2>/dev/null | grep -i '^php' || true)
    if [ -n "$pending" ]; then
        warn "Hay paquetes PHP pendientes de actualizar (apt):"
        echo "$pending" | sed 's/^/        /'
    else
        ok "No hay paquetes PHP pendientes de actualizar (apt)."
    fi
elif command -v dnf >/dev/null 2>&1; then
    pending=$(dnf -q check-update 'php*' 2>/dev/null | awk 'NF>=2 && $1 ~ /^php/' || true)
    if [ -n "$pending" ]; then
        warn "Hay paquetes PHP pendientes de actualizar (dnf):"
        echo "$pending" | sed 's/^/        /'
    else
        ok "No hay paquetes PHP pendientes de actualizar (dnf)."
    fi
else
    info "Gestor de paquetes no reconocido: revisa las actualizaciones manualmente."
fi

echo
echo "=== Resumen ==="
echo "Fallos: ${ISSUES}   Avisos: ${WARNINGS}"
if [ "$ISSUES" -gt 0 ]; then
    echo "Acción recomendada: actualiza PHP a la versión corregida indicada en el aviso oficial."
    exit 1
elif [ "$WARNINGS" -gt 0 ]; then
    echo "Revisa los avisos anteriores."
    exit 1
fi
echo "Sistema sin problemas detectados por este script."
exit 0
