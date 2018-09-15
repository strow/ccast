#!/bin/bash
#
# usage: sbatch one_off.sh
#

#SBATCH --job-name=one_off
#SBATCH --partition=batch
#SBATCH --qos=medium_prod
#SBATCH --account=pi_strow
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=12000

# matlab options
MATLAB=/usr/cluster/matlab/2016b/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

# run the matlab wrapper
srun --output=one-off_%j.out \
  $MATLAB $MATOPT -r "one_off1; exit"

