#!/bin/bash
#
# usage: sbatch ccast_batch.sh doy yyyy
#

# sbatch options
#SBATCH --job-name=ccast
#SBATCH --partition=batch
#SBATCH --qos=long_contrib
#SBATCH --account=pi_strow
#SBATCH --ntasks=30
#SBATCH --mem-per-cpu=8000
# #SBATCH --nodes=2
# #SBATCH --ntasks-per-node=2
# #SBATCH --output=ccast_test.out
# #SBATCH --error=ccast_test.err
# #SBATCH --qos=medium
# #SBATCH --begin=now+6hours

# srun options
# OUTPUT='--output=ccast_%j_%t.out'
# ERROR='--error=ccast_%j.err'
# LABEL='--label'

# matlab options
MATLAB=matlab
# MATLAB=/usr/cluster/matlab/r2013a/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

# run the matlab wrapper
srun --output=ccast_%j_0_%t.out \
    $MATLAB $MATOPT -r "ccast_batch($1, $2); exit"

# run the matlab wrapper
srun --output=ccast_%j_1_%t.out \
    $MATLAB $MATOPT -r "ccast_batch($1+30, $2); exit"

# run the matlab wrapper
srun --output=ccast_%j_2_%t.out \
    $MATLAB $MATOPT -r "ccast_batch($1+60, $2); exit"

# run the matlab wrapper
srun --output=ccast_%j_3_%t.out \
   $MATLAB $MATOPT -r "ccast_batch($1+90, $2); exit"

