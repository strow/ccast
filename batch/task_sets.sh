#!/bin/bash
#
# NAME
#   task_sets -- run ccast on doy = job array ID + process ID
#
# SYNOPSIS
#   sbatch --array=<doy base> task_sets.sh <fnx> <year>
#
# fnx values include
#   SDR_npp_LR, SDR_npp_H2, SDR_npp_H3, SDR_j1_LR, SDR_j1_H4,
#   L1a_npp_LR, L1a_npp_H2, L1a_npp_H3, L1a_j1_H4
#
# The <doy base> spec should normally include a %1 suffix, to run
# only one job array step at a time, since each step will run ntask
# tasks, as set below.
#
# For example if we have --ntasks=15, we would want something
# like --array=339,354%1 to run two job array steps of 15 days each.
# (Actually, the second set will be truncated so as not to run past
# the end of the year.)  The key idea is simply that the job array
# steps should be multiples of ntasks.
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
#SBATCH --ntasks=30
#SBATCH --ntasks-per-node=5

# exclude list
# #SBATCH --exclude=cnode[007,009]
#SBATCH --exclude=cnode021

# matlab options
MATLAB=/usr/ebuild/software/MATLAB/2020a/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

srun --output=$1_%A_%a_%t.out \
   $MATLAB $MATOPT -r "task_sets('$1', $2); exit"

