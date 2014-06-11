#!/bin/bash
#
# run do_rdr2mat as a single cluster task
#

#SBATCH --job-name=rdr2mat
#SBATCH --partition=batch
#SBATCH --qos=long_contrib
#SBATCH --account=pi_strow
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=8000
# #SBATCH --output=rdr2mat.out
# #SBATCH --error=rdr2mat.err

MATLAB=/usr/cluster/matlab/r2013a/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

# run the matlab wrapper
srun --output=rdr2mat_%j_%t.out $MATLAB $MATOPT -r "do_rdr2mat; exit"

