#!/bin/bash -e
source samtools-1.9
samtools view -H Oreochromis_mossambicus_HiFi.bam.sam | grep  "@SQ" >  Oreochromis_mossambicus_header.txt
sed -i 's/@SQ\tSN://g; s/LN:/10000\t/g' Oreochromis_mossambicus_header.txt
awk 'BEGIN{FS="\t"; OFS=FS} {print $1, $2, ($3 - 10000)}' Oreochromis_mossambicus_header.txt > Oreochromis_mossambicus_trimmed.bed
awk '($3 > 100000)' Oreochromis_mossambicus_trimmed.bed > Oreochromis_mossambicus_trimmed_100kb.bed

samtools view -h -o Oreochromis_mossambicus_trimmed.sam -L Oreochromis_mossambicus_trimmed_100kb.bed Oreochromis_mossambicus_HiFi.bam.sam
