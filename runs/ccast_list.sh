#!/bin/bash
#
# usage: sbatch ccast_rerun.sh
#
# edit the ccast_rerun call at the end, as needed
#

# sbatch options
#SBATCH --job-name=CCAST
#SBATCH --partition=batch
#SBATCH --qos=long_contrib
#SBATCH --account=pi_strow
#SBATCH --ntasks=2
#SBATCH --mem-per-cpu=8000
# #SBATCH --nodes=2
# #SBATCH --ntasks-per-node=2
# #SBATCH --output=ccast_test.out
# #SBATCH --error=ccast_test.err
# #SBATCH --qos=medium
# #SBATCH --begin=now+6hours

# srun options
OUTPUT='--output=ccast_%j_%t.out'
ERROR='--error=ccast_%j.err'
# LABEL='--label'

# matlab options
MATLAB=matlab
# MATLAB=/usr/cluster/matlab/r2013a/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

# run the matlab wrapper
srun $OUTPUT $ERROR $LABEL $MATLAB $MATOPT \
  -r "ccast_rerun([136, 137], 2012); exit"

