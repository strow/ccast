#!/bin/bash
#
# usage: sbatch geo_prepro.sh doy1 doy2 yyyy
#

#SBATCH --job-name=geo_prepro
#SBATCH --partition=prod
#SBATCH --qos=normal
#SBATCH --account=pi_strow
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=12000

# new bad node list
#SBATCH --exclude=n126,n150

# matlab options
MATLAB=/usr/cluster/matlab/2016a/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

# run the matlab wrapper
srun --output=geopro_%j.out \
  $MATLAB $MATOPT -r "addpath ../source; geo_prepro($1, $2, $3); exit"

