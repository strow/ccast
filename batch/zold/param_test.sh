#!/bin/bash
#
# example usage: sbatch param_test.sh 101 102 103 tuna
#

#SBATCH --job-name=prepro
#SBATCH --partition=batch
#SBATCH --qos=short
#SBATCH --account=pi_strow
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=2000

# matlab options
MATLAB=/usr/cluster/matlab/2014a/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

# run the matlab wrapper
srun --output=param_test_%j.out \
  $MATLAB $MATOPT -r "addpath ../source; param_test($1, $2, $3, '$4'); exit"

