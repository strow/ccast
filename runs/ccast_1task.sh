#!/bin/bash
#
# usage: sbatch ccast_1task.sh doy year
#

# sbatch options
#SBATCH --job-name=ccast_1task
#SBATCH --partition=batch
#SBATCH --qos=medium
#SBATCH --account=pi_strow
#SBATCH --mem-per-cpu=10000
#SBATCH --ntasks=1

# matlab options
MATLAB=/usr/cluster/matlab/2014a/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

# job step 1
srun --output=ccast_%j_0_%t.out \
    $MATLAB $MATOPT -r "ccast_batch($1, $2); exit"

