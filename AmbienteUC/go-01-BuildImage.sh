#!/bin/bash

# Source the environment variables from go-00-environment.sh
source ./go-00-environment.sh

echo "Removing old data..."
docker builder prune --force

echo "Creating CDLE image for Winter Semester ${SemesterStart}/${SemesterEnd} (Version ${Version})..."

cd Docker
docker build -t cdle.ubuntu.${SemesterStart}.${SemesterEnd}.v${Version} .
cd ..

read -p "Press any key to continue..."
