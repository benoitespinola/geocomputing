#!/bin/bash -l
#SBATCH -J python_grass_test
#SBATCH -o out.txt
#SBATCH -e err.txt
#SBATCH -t 00:02:00
#SBATCH --cpus-per-task=5
#SBATCH --mem=10000
#SBATCH -p test
module load geo-env fftw grass
python standalone.py 2 2 4
