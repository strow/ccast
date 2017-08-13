#!/bin/bash
#
# usage: sbatch airs_batchZ
#

#SBATCH --job-name=airs_batchZ
#SBATCH --partition=batch
#SBATCH --qos=long_contrib
#SBATCH --account=pi_strow
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=12000

# matlab options
MATLAB=/usr/cluster/matlab/2016b/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

# run the matlab wrapper
srun --output=airs_batchZ_%j.out \
  $MATLAB $MATOPT -r "addpath lat_subset; airs_tbinZ; exit"

