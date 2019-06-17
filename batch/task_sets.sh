#!/bin/bash
#
# NAME
#   task_sets -- run ccast on doy = job array ID + process ID
#
# SYNOPSIS
#   sbatch --array=<doy base> task_sets.sh <fnx> <year>
#
# fnx values include
#   SDR_npp_LR, SDR_npp_HR, SDR_j1_LR, SDR_j1_HR,
#   L1a_npp_H2, L1a_npp_H3, L1a_j1_H4
#

# sbatch options
#SBATCH --job-name=ccast
#SBATCH --partition=high_mem
#SBATCH --qos=medium+
# #SBATCH --qos=normal+
#SBATCH --account=pi_strow
#SBATCH --mem-per-cpu=16000
#SBATCH --oversubscribe
# #SBATCH --ntasks=25
#SBATCH --ntasks=15
#SBATCH --ntasks-per-node=5

# matlab options
MATLAB=/usr/ebuild/software/MATLAB/2018b/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

srun --output=$1_%A_%a_%t.out \
   $MATLAB $MATOPT -r "task_sets('$1', $2); exit"

