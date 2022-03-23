#!/bin/bash -e
conda activate py_anaconda_5.3.0
conda activate python37
bamCoverage -p 30 -b Oreochromis_mossambicus_HiFi_non_overlapping.bam -of bedgraph -o Oreochromis_mossambicus_HiFi_non_overlapping.bg -bs 1000


#To get the distribution of coverage across the bedgraph:


awk '{print $4}'  O_niloticus_UMD_non_overlapping.bedgraph | sort -nr | uniq -c > O_niloticus_UMD_cov_dist.txt

#The mean coverage for each file is about 30x coverage, so first of all, filter for intervals that are >29 and then merge intervals that are within 1kb of each other
source bedtools-2.30.0
awk '($4>29) {print $0}' O_niloticus_UMD_non_overlapping.bedgraph | bedtools merge -d 1001  -i stdin > O_niloticus_UMD_non_overlapping_hicov_merged.bedgraph

#Then for each assembly, extract the reads that within each interval, and write those reads to a file named after the interval, e.g.
10_1767000_1769000.txt

python ~/python_scripts/bedtools/bam_reads_from_bed.py O_niloticus_HiFi_non_overlapping_hicov_merged.bedgraph ../O_niloticus_HiFi_10x_sm_non_overlapping.bam
conda deactivate

#So now we have three directories, gift_intervals, umd_intervals, and mossambicus_intervals, with a file for each interval, that contains the name of the reads mapped within that interval (including overlaps).
#Then, for each directory, read each file into a Python dictionary, where the keys are intervals and the values are the reads (as a set).
#Then, starting with the GIFT dictionary, do nested iterations of the sets and see which combination of three intervals share the largest number of reads.

python ~/python_scripts/bedtools/bam_reads_find_best_donors.py gift_intervals/ umd_intervals/ mossambicus_intervals/ best_hits.txt
