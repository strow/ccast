#!/bin/bash
#
# usage: sbatch --array=<array spec> ccast_array.sh <year>
#
# typical calls
#   sbatch --array=306-365%20 ccast_array.sh 2015
#   sbatch --array=349,354,361 ccast_array.sh 2015
#

# sbatch options
#SBATCH --job-name=ccast
#SBATCH --output=ccast_%A_%a.out
#SBATCH --partition=batch
#SBATCH --qos=medium_prod
#SBATCH --account=pi_strow
#SBATCH --mem-per-cpu=16000

# new bad node list
#SBATCH --exclude=n71

# matlab options
MATLAB=/usr/cluster/matlab/2016a/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

srun $MATLAB $MATOPT -r "ccast_array($1); exit"

