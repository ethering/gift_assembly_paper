#!/bin/bash -e
source sspace-longread_1.1
srun perl SSPACE-LongRead.pl -c Tilapia_hifiasm.ctg.fa -p tilapia.trimmedReads.fasta -t 12 -k 1
