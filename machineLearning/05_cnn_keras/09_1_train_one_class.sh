#!/bin/bash
#SBATCH --account=project_2002044
#SBATCH --partition=gpu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem=6G
#SBATCH --time=1:00:00
#SBATCH --gres=gpu:v100:1,nvme:1 #Local disk in Gb
#SBATCH --reservation ml10

module load tensorflow/nvidia-19.11-tf2-py3
#tar cvf spruce.tar image_training_tiles_650 label_tiles_650
#TOFIX: set your own tiles folder
tar xf /scratch/project_2002044/test/student_0000/tiles/spruce.tar -C $LOCAL_SCRATCH

echo $LOCAL_SCRATCH
ls $LOCAL_SCRATCH

srun singularity_wrapper exec python3 09_1_train.py $LOCAL_SCRATCH
