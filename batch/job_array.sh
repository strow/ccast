#!/bin/bash
#
# NAME
#   job_array -- run ccast on doy = job array ID
#
# SYNOPSIS
#   sbatch --array=<doy list> job_array.sh <fnx> <year>
#
# fnx values include
#   SDR_npp_LR, SDR_npp_H2, SDR_npp_H3, SDR_j1_LR, SDR_j1_H4,
#   L1a_npp_LR, L1a_npp_H2, L1a_npp_H3, L1a_j1_H4
#

# sbatch options
#SBATCH --job-name=ccast
#SBATCH --partition=high_mem
# #SBATCH --partition=batch
#SBATCH --constraint=lustre
# #SBATCH --constraint=hpcf2009
#SBATCH --qos=medium+
# #SBATCH --qos=normal+
#SBATCH --account=pi_strow
#SBATCH --mem-per-cpu=20000
#SBATCH --oversubscribe
# #SBATCH --exclusive

# exclude list
# #SBATCH --exclude=cnode[007,009]

# matlab options
MATLAB=/usr/ebuild/software/MATLAB/2018b/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

srun --output=$1_%A_%a.out \
   $MATLAB $MATOPT -r "job_array('$1', $2); exit"

