#!/bin/bash

echo "Setting global variables..."

SemesterStart=2024
SemesterEnd=2025
Version=1

ComposeFile=docker-compose-cdle-${SemesterStart}-${SemesterEnd}.yml

export SemesterStart SemesterEnd Version ComposeFile
