#!/bin/bash -e
REFERENCE=$1
source repeatmasker-4.0.8
srun RepeatMasker -species cichlidae -pa 40 -xsmall $REFERENCE
