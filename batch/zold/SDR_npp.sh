#!/bin/bash
#
# usage: sbatch --array=<array spec> SDR_npp.sh <year>
#
# typical calls
#   sbatch --array=306-365%20 SDR_npp.sh 2018
#   sbatch --array=349,354,361 SDR_npp.sh 2018
#

# sbatch options
#SBATCH --job-name=SDR_npp
#SBATCH --output=SDR_npp_%A_%a.out
#SBATCH --partition=high_mem
# #SBATCH --partition=batch
# #SBATCH --constraint=hpcf2009
#SBATCH --qos=medium+
#SBATCH --account=pi_strow
#SBATCH --mem-per-cpu=16000
#SBATCH --oversubscribe
#SBATCH --nodelist=cnode042

# exclude list
# #SBATCH --exclude=cnode[100-199]

# matlab options
MATLAB=/usr/ebuild/software/MATLAB/2018b/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

srun $MATLAB $MATOPT -r "SDR_npp($1); exit"

