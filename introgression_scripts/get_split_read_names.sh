#!/bin/bash -e
awk 'NR==FNR{A[$1];next}$1 in A' O_niloticus_UMD_NMBU.bam.sam_chimeric.txt  Oreochromis_mossambicus_trimmed.sam_chimeric.txt | awk '{print $1}' | uniq > UMD_mossambicus_intersect.txt

cut -f 1 O_niloticus_HiFi_10x_sm.bam.sam_chimeric.txt | sort | uniq > gift_unique_reads.txt

awk 'FNR==NR {a[$0]++; next} !($0 in a)' gift_unique_reads.txt UMD_mossambicus_intersect.txt > split_reads_not_in_gift.txt
