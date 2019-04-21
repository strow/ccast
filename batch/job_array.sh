#!/bin/bash
#
# NAME
#   job_array -- run ccast on doy = job array ID
#
# SYNOPSIS
#   sbatch --array=<doy list> job_array.sh <fnx> <year>
#
# fnx values include
#   SDR_npp_LR, SDR_npp_HR, SDR_j1_LR, SDR_j1_HR,
#   L1a_npp_H2, L1a_npp_H3, L1a_j1_H4
#

# sbatch options
#SBATCH --job-name=ccast
#SBATCH --partition=batch
#SBATCH --constraint=hpcf2009
# #SBATCH --partition=high_mem
#SBATCH --qos=medium+
# #SBATCH --qos=normal+
#SBATCH --account=pi_strow
#SBATCH --mem-per-cpu=16000
#SBATCH --oversubscribe

# exclude list
#SBATCH --exclude=cnode[203,204,212,213,240,260,284]

# matlab options
MATLAB=/usr/ebuild/software/MATLAB/2018b/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

srun --output=$1_%A_%a.out \
   $MATLAB $MATOPT -r "job_array('$1', $2); exit"

