#!/bin/bash -e

bam=$1

basebam=$(basename -- "$bam")
basebam="${bam%.*}"
basebam=$(echo $bam | awk -F '.bam' '{print $1}')
echo $basebam
outbam=$basebam\_non_overlapping.bam

source picardtools-2.25.7
picard FilterSamReads I=$bam O=$outbam  READ_LIST_FILE=non_overlapping_reads.txt FILTER=includeReadList
