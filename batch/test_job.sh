#!/bin/bash
#
# NAME
#   test_job -- simple job array test
#
# SYNOPSIS
#   sbatch --array=<list> test_job.sh
#

# sbatch options
#SBATCH --job-name=test
#SBATCH --partition=batch
#SBATCH --constraint=hpcf2009
# #SBATCH --partition=high_mem
# #SBATCH --qos=medium+
# #SBATCH --qos=normal+
#SBATCH --qos=short+
#SBATCH --account=pi_strow
#SBATCH --mem-per-cpu=16000
#SBATCH --oversubscribe

# exclude list
#SBATCH --exclude=cnode[203,204,260,267]

srun --output=test_%A_%a.out test_aux.sh

