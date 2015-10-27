#!/bin/bash
#
# usage: sbatch ccast_batch.sh doy yyyy
#
# ccast_batch.sh d1 yyyy started with m tasks will process days d1,
# d1+1, d1+2, ..., d1+4*m-1, in 4 job steps.  For m tasks, the job
# step offsets should be 0, m, 2*m, 3*m, etc.

# sbatch options
#SBATCH --job-name=ccast
#SBATCH --partition=batch
#SBATCH --qos=long_contrib
#SBATCH --account=pi_strow
#SBATCH --mem-per-cpu=12000
#SBATCH --ntasks=30

# matlab options
MATLAB=/usr/cluster/matlab/2014a/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

# job step 1
srun --output=ccast_%j_0_%t.out \
    $MATLAB $MATOPT -r "ccast_batch($1, $2); exit"

# job step 2
srun --output=ccast_%j_1_%t.out \
   $MATLAB $MATOPT -r "ccast_batch($1+30, $2); exit"

# job step 3
srun --output=ccast_%j_2_%t.out \
  $MATLAB $MATOPT -r "ccast_batch($1+60, $2); exit"

# job step 4
# srun --output=ccast_%j_3_%t.out \
#   $MATLAB $MATOPT -r "ccast_batch($1+180, $2); exit"

