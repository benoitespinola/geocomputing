#!/bin/bash -l
#SBATCH --account=project_2002044
#SBATCH --job-name=r_multi_proc
#SBATCH --output=output.txt
#SBATCH --error=errors.txt
#SBATCH --time=00:05:00
#Reserve cores for 1 master + 3 workers
#SBATCH --ntasks=4
#Test partition is used for testing, for real jobs use either serial or parallel depending on how many nodes you need.
#SBATCH --partition=test
#SBATCH --mem-per-cpu=1000

module load r-env-singularity

# If you have installed packages this helps resolve problems related to those
if test -f ~/.Renviron; then
    sed -i '/TMPDIR/d' ~/.Renviron
    sed -i '/OMP_NUM_THREADS/d' ~/.Renviron   
fi

# Specify a temp folder path
# echo "TMPDIR=/scratch/<project>/tmp" >> ~/.Renviron
echo "TMPDIR=$PWD/tmp" >> ~/.Renviron

srun singularity_wrapper exec RMPISNOW --no-save --slave -f Calc_contours_future_cluster.R
