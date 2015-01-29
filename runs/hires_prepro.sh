#!/bin/bash
#
# usage: sbatch hires_prepro.sh doy1 doy2 yyyy 
#

#SBATCH --job-name=prepro
#SBATCH --partition=batch
#SBATCH --qos=long_contrib
#SBATCH --account=pi_strow
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=10000

# matlab options
MATLAB=/usr/cluster/matlab/2014a/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

# run the matlab wrapper
srun --output=hires_prepro_%j.out \
  $MATLAB $MATOPT -r "addpath ../source; hires_prepro($1, $2, $3); exit"

