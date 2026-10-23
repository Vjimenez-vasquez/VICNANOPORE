/media/ins-bio/DATA02/GAPP/RIM/_assets/kraken2/k2-pluspf/

# 0. crear carpetas, setear DB y nucleos
mkdir -p 3.taxonomy/ ; 

OUTPUT_DIR="3.taxonomy"
# DB="/media/ins-bio/DATA02/GAPP/RIM/_assets/kraken2/k2-pluspf/"
DB="/media/ins-bio/DATA01/data_base_download/kraken2_viral/"
THREADS=20

# 1. Identificacion con KRAKEN2 + KRONA-PLOT
for GZ in *.fastq.gz
do
p1=$(basename $GZ .fastq.gz)
echo "KRAKEN2: procesando la muestra '$GZ'..."
kraken2 --db $DB --threads $THREADS --gzip-compressed --use-names --report ${OUTPUT_DIR}/${p1}_report.txt --output ${OUTPUT_DIR}/${p1}_kraken_out.txt $GZ ;
bracken -d $DB -i ${OUTPUT_DIR}/${p1}_report.txt -o ${OUTPUT_DIR}/${p1}_bracken.txt -l S ; 
cat ${OUTPUT_DIR}/${p1}_report.txt | cut -f 3,5 >  ${OUTPUT_DIR}/${p1}.krona ;
echo "KRAKEN2: la muestra '$GZ' ha sido procesada ..."
echo " "
done

mkdir -p 3.taxonomy/KRAKEN2_report/ 3.taxonomy/KRAKEN2_out/ 3.taxonomy/BRACKEN_species/ 3.taxonomy/BRACKEN_counts/ 3.taxonomy/KRONA_input/;
mv 3.taxonomy/*_report.txt 3.taxonomy/KRAKEN2_report/ ; 
mv 3.taxonomy/*_out.txt 3.taxonomy/KRAKEN2_out/ ;
mv 3.taxonomy/*_bracken_species.txt 3.taxonomy/BRACKEN_species/ ;
mv 3.taxonomy/*_bracken.txt 3.taxonomy/BRACKEN_counts/ ;

echo "¡KRAKEN2 HA FINALIZADO!"
echo ""
echo "KRONA: generando plots de KRONA..."
ktImportTaxonomy -o multi-krona.html 3.taxonomy/*.krona ;
mv 3.taxonomy/*.krona 3.taxonomy/KRONA_input/ ;
echo "KRONA: el resultado se encuentran en el archivo 'multi-krona.html'";
echo "Be hAPpY =)"

# 2. Identificacion con BRACKEN
DB="/media/ins-bio/DATA02/GAPP/RIM/_assets/kraken2/k2-pluspf/" ;
bracken -d $DB -i barcode04_report.txt -o barcode04.bracken.txt -l S ; 

