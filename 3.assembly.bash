#!/usr/bin/env bash

# ==============================================================================
# CONFIGURACIÓN DE RUTAS Y PARÁMETROS
# ==============================================================================
INPUT_DIR="./mapping"
OUTPUT_DIR="./flye_assemblies"
THREADS=20

# Tamaño estimado del genoma
GENOME_SIZE="100k"

mkdir -p "${OUTPUT_DIR}"

echo "=== Inicio de Ensamblado De Novo con Flye (Modo SUP + SISPA) ==="

for fq in "${INPUT_DIR}"/*_no_human.fastq; do
    [ -e "${fq}" ] || continue

    prefix=$(basename "${fq}" _no_human.fastq)
    SAMPLE_OUT_DIR="${OUTPUT_DIR}/${prefix}"
    mkdir -p "${SAMPLE_OUT_DIR}"

    echo "------------------------------------------------------------------"
    echo "Ensamblando muestra: ${prefix}..."

    # Ejecución de Flye con --nano-hq (modo SUP) 
    flye \
        --nano-hq "${fq}" \
        --out-dir "${SAMPLE_OUT_DIR}" \
        --threads "${THREADS}" \
        --genome-size "${GENOME_SIZE}" \
        > "${SAMPLE_OUT_DIR}/flye.log" 2>&1

    echo "Ensamblado completado para ${prefix}."
    echo "Contigs generados en: ${SAMPLE_OUT_DIR}/assembly.fasta"
    echo "--------------------------------------------------"
done

echo "=== Ensamblado completado para todas las muestras ==="