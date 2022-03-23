#!/bin/bash -e
source smrtlink-8.0.0.80529_CBG
srun bam2fastq -o  m64036_200310_170612.subreads m64036_200310_170612.subreads.bam
