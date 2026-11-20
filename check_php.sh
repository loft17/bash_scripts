#!/usr/bin/env bash
# check_php_versiones.sh - Comprueba los paquetes php*-cli instalados (Debian/Ubuntu)
# frente a las versiones mínimas definidas en VERSIONES_MINIMAS.
#
# Uso:
#   ./check_php_versiones.sh                  # usa las versiones de la variable
#   ./check_php_versiones.sh 8.3=8.3.40       # opcional: sustituye la variable por los argumentos
#
# Formato de cada versión: RAMA=VERSION_MINIMA
# Las ramas instaladas que no tengan versión mínima se marcan como "[SIN DATOS]".
# Código de salida: 0 = todas las ramas cumplen, 1 = alguna no cumple o no hay datos.

set -u

# ---------------------------------------------------------------------------
# EDITA AQUÍ: una línea por rama, con la versión mínima (corregida) del aviso.
# Para quitar una rama, borra su línea o ponle un # delante.
declare -A VERSIONES_MINIMAS=(
    [8.2]="8.2.35"
    [8.3]="8.3.36"
    [8.4]="8.4.27"
    [8.5]="8.5.12"
)
# ---------------------------------------------------------------------------

if ! command -v dpkg-query >/dev/null 2>&1; then
    echo "Este script necesita dpkg (Debian/Ubuntu)."
    exit 2
fi

# Si se pasan argumentos (RAMA=VERSION), sustituyen a la lista de arriba.
if [ "$#" -gt 0 ]; then
    declare -A VERSIONES_MINIMAS=()
    for entrada in "$@"; do
        if [[ "$entrada" != *=* ]]; then
            echo "Entrada no válida: '$entrada' (usa RAMA=VERSION)"
            exit 2
        fi
        VERSIONES_MINIMAS["${entrada%%=*}"]="${entrada#*=}"
    done
fi
declare -n MIN=VERSIONES_MINIMAS

PKGS=$(dpkg-query -W -f='${Package} ${Version}\n' 'php[0-9].*-cli' 2>/dev/null)
if [ -z "$PKGS" ]; then
    echo "No se han encontrado paquetes php*-cli instalados."
    exit 1
fi

status=0
while read -r pkg ver; do
    rama=$(echo "$pkg" | sed -E 's/^php([0-9]+\.[0-9]+).*/\1/')
    if [ -z "${MIN[$rama]+x}" ]; then
        echo "[SIN DATOS]  PHP $rama ($ver): no hay versión mínima definida para esta rama."
        status=1
        continue
    fi
    min="${MIN[$rama]}"
    if dpkg --compare-versions "$ver" ge "$min"; then
        echo "[OK]         PHP $rama ($ver) cumple el mínimo $min"
    else
        echo "[VULNERABLE] PHP $rama ($ver) es inferior al mínimo $min"
        status=1
    fi
done <<< "$PKGS"

exit $status
