#!/usr/bin/env bash

# ==============================================================================
# CONFIGURACIÓN DE RUTAS Y PARÁMETROS
# ==============================================================================
INPUT_DIR="./mapping"
OUTPUT_DIR="./kraken2_results"
KRAKEN_DB="/media/ins-bio/DATA02/GAPP/RIM/_assets/kraken2/k2-RVDB/"
THREADS=20

# Crear directorio de resultados si no existe
mkdir -p "${OUTPUT_DIR}"

echo "=== Inicio de clasificación taxonómica con Kraken 2 ==="
echo "Base de datos: ${KRAKEN_DB}"
echo "Directorio de entrada: ${INPUT_DIR}"
echo "--------------------------------------------------"

# ==============================================================================
# BUCLE DE PROCESAMIENTO
# ==============================================================================
for fq in "${INPUT_DIR}"/*_no_human.fastq; do
    # Verificar si existen archivos con el patrón
    [ -e "${fq}" ] || { echo "No se encontraron archivos *_no_human.fastq en ${INPUT_DIR}"; exit 1; }

    # Obtener el prefijo (ejemplo: barcode50 a partir de barcode50_no_human.fastq)
    prefix=$(basename "${fq}" _no_human.fastq)

    echo "Procesando muestra: ${prefix}..."

    # Ejecución de Kraken 2
    kraken2 \
        --db "${KRAKEN_DB}" \
        --threads "${THREADS}" \
        --use-names \
        --report "${OUTPUT_DIR}/${prefix}_report.txt" \
        --output "${OUTPUT_DIR}/${prefix}_kraken_out.txt" \
        "${fq}"

    echo "Reporte generado: ${OUTPUT_DIR}/${prefix}_report.txt"
    echo "--------------------------------------------------"
done

echo "=== Análisis con Kraken 2 completado con éxito ==="