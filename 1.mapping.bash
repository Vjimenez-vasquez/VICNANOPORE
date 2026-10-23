#!/usr/bin/env bash

# Crear la carpeta de salida 
mkdir -p mapping

REF_HUMAN="/media/ins-bio/DATA01/data_base_download/T2T-CHM13/CHM13v2.0_genomic.fasta"

for r1 in *.fastq.gz; do
  [ -e "$r1" ] || continue
  prefix=$(basename "$r1" .fastq.gz)
  
  echo "Procesando dehosting para: ${prefix}..."

  # 1. Alineamiento completo (lecturas mapeadas y no mapeadas)
  minimap2 -ax map-ont -t 20 "$REF_HUMAN" "$r1" | samtools view -bS - > "mapping/${prefix}_all.bam"

  # 2. Extraer ÚNICAMENTE las lecturas NO humanas (usando -f 4)
  samtools view -b -f 4 "mapping/${prefix}_all.bam" > "mapping/${prefix}_unaligned.bam"

  # 3. Convertir las lecturas NO humanas a formato FASTQ
  samtools fastq "mapping/${prefix}_unaligned.bam" > "mapping/${prefix}_no_human.fastq"

  # (Opcional) Eliminar el BAM intermedio grande para ahorrar espacio en disco
  rm "mapping/${prefix}_all.bam"

  echo "Completado ${prefix}. Lecturas no humanas en mapping/${prefix}_no_human.fastq"
done