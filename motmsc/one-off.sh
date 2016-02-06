#!/bin/bash
#
# usage: sbatch one-off.sh
#

#SBATCH --job-name=one-off
#SBATCH --partition=batch
#SBATCH --qos=normal
#SBATCH --account=pi_strow
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=12000

# matlab options
MATLAB=/usr/cluster/matlab/2014a/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

# run the matlab wrapper
srun --output=one-off_%j.out \
  $MATLAB $MATOPT -r "mean_cfovs; exit"

