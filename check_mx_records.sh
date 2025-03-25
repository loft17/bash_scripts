#!/bin/bash

# Función para imprimir en verde
print_green() {
    echo -e "\033[0;32m$1\033[0m"
}

# Comprobación de si se pasó la opción -i
while getopts "i:" opt; do
    case $opt in
        i)
            archivo="$OPTARG"
            ;;
        \?)
            echo "Uso: $0 -i archivo_de_dominios.txt"
            exit 1
            ;;
    esac
done

# Verificar si se pasó un archivo
if [ -z "$archivo" ]; then
    echo "Por favor, proporciona un archivo con dominios usando -i."
    exit 1
fi

# Verificar si el archivo existe
if [ ! -f "$archivo" ]; then
    echo "El archivo '$archivo' no existe."
    exit 1
fi

# Leer el archivo línea por línea
while IFS= read -r dominio; do
    # Asegurarse de que la línea no esté vacía
    if [[ -n "$dominio" ]]; then
        # Imprimir el dominio en verde
        print_green "$dominio:"
        
        # Usar dig para obtener los registros MX y mostrarlos ordenados
        dig +short "$dominio" MX | sort | while read -r mx; do
            echo "    $mx"
        done
        echo ""
    fi
done < "$archivo"
