#!/bin/bash -e
reference=$1
filename=$(basename -- "$reference")
base_name="${filename%.*}"


source pbmm2-1.4.0
source samtools-1.9
pbmm2 index $reference $base_name.mmi
pbmm2 align $reference lima.bc1021_BAK8B_OA--bc1021_BAK8B_OA.bam $base_name.bam --sort -j 32 --preset "HIFI" --log-level INFO

srun samtools view -h -o $base_name.sam $base_name.bam
