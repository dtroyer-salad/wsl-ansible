#!/bin/bash
# run-gpu-containers.sh
#
# Run some test containers to validate configuration

docker run --rm --gpus all nvidia/cuda:11.6.2-base-ubuntu20.04 nvidia-smi

docker run --gpus all nvcr.io/nvidia/k8s/cuda-sample:nbody 9 nbody -gpu -benchmark
