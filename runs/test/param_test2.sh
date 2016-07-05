#!/bin/bash
#
# example usage: bash param_test2.sh 101 102 103 tuna
#

# matlab options
MATLAB=/usr/cluster/matlab/2014a/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

echo "$1, $2, $3, $4"
echo "$1, $2, $3, '$4'"

# run the matlab wrapper
$MATLAB $MATOPT -r "addpath ../source; param_test($1, $2, $3, '$4'); exit"

