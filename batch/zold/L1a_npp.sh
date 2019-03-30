#!/bin/bash
#
# usage: sbatch --array=<array spec> L1a_npp.sh <year>
#
# typical calls
#   sbatch --array=306-365%20 L1a_npp.sh 2018
#   sbatch --array=349,354,361 L1a_npp.sh 2018
#

# sbatch options
#SBATCH --job-name=L1a_npp
#SBATCH --output=L1a_npp_%A_%a.out
# #SBATCH --partition=batch
#SBATCH --partition=high_mem
#SBATCH --qos=normal+
#SBATCH --account=pi_strow
#SBATCH --mem-per-cpu=16000
#SBATCH --share

# exclude list
#SBATCH --exclude=cnode[101-134]

# matlab options
MATLAB=/usr/ebuild/software/MATLAB/2018b/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

srun $MATLAB $MATOPT -r "L1a_npp($1); exit"

