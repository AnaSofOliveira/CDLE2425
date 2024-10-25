#!/bin/bash

# Source the environment variables from go-00-environment.sh
source ./go-00-environment.sh

echo "Creating container..."
docker compose -f ${ComposeFile} -p cdle-${SemesterStart}-${SemesterEnd}-v${Version} up -d

read -p "Press any key to continue..."
