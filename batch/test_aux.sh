#!/bin/bash
#

echo job ID $SLURM_JOB_ID
echo job array ID $SLURM_ARRAY_TASK_ID
echo "one, two, boogaloo,"
echo "cheese for me is cheese for you!"
sleep 30
echo "all done"
