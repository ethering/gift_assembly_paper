#!/bin/bash -e
#Filter the chimeric read file for the list of reads that are in the filtered/split bam files above, so we have a bam file and chimeric read file with the same reads in them.
awk 'FNR==NR{a[$1]; next} ($1 in a){delete a[$1]; print $0}' split_reads_not_in_gift.txt O_niloticus_UMD_NMBU_trimmed.sam_chimeric.txt > UMD_not_in_gift.txt
awk 'FNR==NR{a[$1]; next} ($1 in a){delete a[$1]; print $0}'  split_reads_not_in_gift.txt Oreochromis_mossambicus_trimmed.sam_chimeric.txt> mosambicus_not_in_gift.txt
