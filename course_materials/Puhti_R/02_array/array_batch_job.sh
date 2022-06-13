#!/bin/bash
#SBATCH --account=project_2002044
#SBATCH -J array_job
#SBATCH -o array_job_out_%A_%a.txt
#SBATCH -e array_job_err_%A_%a.txt
#SBATCH -t 00:02:00
#SBATCH --mem-per-cpu=1000
#SBATCH --array=1-3
#SBATCH -n 1
#SBATCH -p small

# load the Puhti module for R
module load r-env-singularity

if test -f ~/.Renviron; then
    sed -i '/TMPDIR/d' ~/.Renviron
fi

# Specify a temp folder path
# echo "TMPDIR=/scratch/<project>/tmp" >> ~/.Renviron
echo "TMPDIR=$PWD/tmp" >> ~/.Renviron

# read the file that has filepaths for mapsheets and pick one row according to variable $SLURM_ARRAY_TASK_ID
name=$(sed -n "$SLURM_ARRAY_TASK_ID"p ../mapsheets.txt)

# run the analysis command
srun singularity_wrapper exec Rscript Contours_array.R $name
