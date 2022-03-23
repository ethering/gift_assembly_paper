#!/bin/bash -e

source canu-2.1.1
srun canu -correct -p tilapia -d out  genomeSize=1g -pacbio m64036_200310_170612.subreads.fastq.gz
srun canu -trim -p tilapia -d out genomeSize=1g -pacbio -corrected out/tilapia.correctedReads.fasta.gz
#output will be tilapia.trimmedReads.fasta.gz
