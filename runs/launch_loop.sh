#!/bin/bash
#
# usage:  sbatch launch_loop doy1 doy2 year
#

# loop on days of the year
for doy in `seq $1 $2`
do
  echo sbatch ccast_1task.sh $doy $3
  sbatch ccast_1task.sh $doy $3
  sleep 2
done

