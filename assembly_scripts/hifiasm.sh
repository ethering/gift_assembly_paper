#!/bin/bash -e
source hifiasm-0.15
srun hifiasm -o Tilapia_hifiasm -t64 lima.bc1021.fastq
