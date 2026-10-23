#!/usr/bin/env bash

###################
# -1. generar carpetas  #
###################

mkdir -p 1.nanoplot_QC/ ;

###################
# 0. setear parametros #
###################

THREADS=20

########################
# 1. ubicar e inicializar conda #
########################
source "$(conda info --base)/etc/profile.d/conda.sh"

##########################################
# 2. revisar la calidad de resultados con NANOPLOT #
##########################################
conda activate nanoplot ;
for n1 in *.gz
do
p1=$(basename $n1 .fastq.gz)
echo "Analizando la calidad de la muestra '$p1'..."
NanoPlot -t $THREADS -o ${p1}_QC --fastq $n1 --tsv_stats ;
grep -v "Metrics"  ${p1}_QC/NanoStats.txt | sed 's/\t/,/g' > res1
l1=$(cut -f1 -d"," res1 | paste -sd,)
l2=$(cut -f2 -d"," res1 | paste -sd,)
printf "%s\n%s\n" "$l1" "$l2" > ${p1}.res2
rm res1
mv ${p1}_QC/ 1.nanoplot_QC/ ;
done
echo "¡Las muestras fueron analizadas con 'NANOPLOT'!"
conda deactivate ;
echo " "

####################################
# 3. concatenar estadisticas de NANOPLOT #
####################################
echo "...combinando resultados de 'NANOPLOT'"
for sample in *.res2
do
p1=$(basename $sample .res2)
p2=$(grep -v "number_of" $sample)
echo -e "$p1,$p2"
done > statistics.txt 
sed "1i sample,number_of_reads,number_of_bases,median_read_length,mean_read_length,read_length_stdev,n50,mean_qual,median_qual,longest_read_(with_Q):1,longest_read_(with_Q):2,longest_read_(with_Q):3,longest_read_(with_Q):4,longest_read_(with_Q):5,highest_Q_read_(with_length):1,highest_Q_read_(with_length):2,highest_Q_read_(with_length):3,highest_Q_read_(with_length):4,highest_Q_read_(with_length):5,Reads >Q10,Reads >Q15,Reads >Q20,Reads >Q25,Reads >Q30" statistics.txt > nanoplot.statistics.txt ;
rm *.res2 statistics.txt ; 
cat nanoplot.statistics.txt ;
echo " "
echo "¡Los resultados generales de calidad de lecturas se encuentran en el archivo 'nanoplot.statistics.txt'!"
echo " "

######################
# 4. remover adaptadores #
######################
conda activate porechop_abi ; 
for n1 in *.gz
do
p1=$(basename $n1 .fastq.gz)
echo "Eliminando adaptadores con 'PORECHOP' en la muestra '${p1}'..."
porechop_abi -abi -i $n1 -o ${p1}.clean1.fastq.gz -t 30 --no_split  --format fastq.gz
echo " "
done 
conda deactivate ; 

##############################
# 5. filtrar lecturas de calidad inferior #
##############################
conda activate nanofilt ;
for n2 in *.clean1.fastq.gz
do
p1=$(basename $n2 .clean1.fastq.gz)
echo "Eliminando lecturas de baja calidad con 'NANOFILT' en la muestra '${p1}'..."
gunzip -c $n2 | NanoFilt -l 200 -q 15 | gzip > ${p1}.clean2.fastq.gz
echo "Eliminando FASTQ intermedio: '${p1}.clean1.fastq.gz '..."
rm ${p1}.clean1.fastq.gz 
done
echo " "





# Dividir en fragmentos de ~1 millón de lecturas (ajusta según el tamaño de tus lecturas)
zcat barcode53.fastq.gz | split -l 4000000 --filter='gzip > $FILE.gz' - barcode53_chunk_

# Procesar en paralelo, asignando pocos hilos por instancia
ls barcode53_chunk_*.gz | parallel -j 4 'porechop_abi -abi --no_split -i {} -o {.}.clean.fastq.gz -t 4 --format fastq.gz'

# Unir resultados
cat barcode53_chunk_*.clean.fastq.gz > barcode53.clean1.fastq.gz









      

