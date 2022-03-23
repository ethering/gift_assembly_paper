#!/bin/bash -e
bam=$1
source picardtools-2.25.7
picard FilterSamReads I=$bam O=$bam\_split.bam  READ_LIST_FILE=split_reads_not_in_gift.txt FILTER=includeReadList
