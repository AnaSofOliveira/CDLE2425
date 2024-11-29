#!/bin/bash

CORPUS_NAME=gutenberg-small
#CORPUS_NAME=gutenberg-mixed

function usage() {
	echo "Invalid arguments!"
	echo "Usage:"
	echo "$0 <File System type>"
	echo ""
	echo "Where <File System type> can be:"
	echo ""
	echo "local - local file system (file://)"
	echo "HDFS - HDFS file system (hdfs://)"
	echo "NFS - Network File System for input and HDFS for output"
	exit
}

if [[ $# -lt 1 ]]; then
	usage
else
	case "$1" in
		"local")
			FILE_SYSTEM_TYPE=file://
			BASE_DIRECTORY=${HOME}/examples
			
			INPUT=${BASE_DIRECTORY}/input/${CORPUS_NAME}
			INPUT_DIRECTORY=${FILE_SYSTEM_TYPE}${INPUT}

			RUN_MODE="--runner inline"
			;;
		
		"HDFS")
			FILE_SYSTEM_TYPE=hdfs://
			BASE_DIRECTORY=/user/${USER}
			
			INPUT=${BASE_DIRECTORY}/input/${CORPUS_NAME}

			INPUT_DIRECTORY=${FILE_SYSTEM_TYPE}${INPUT}
			
			echo -e "\nCreating input directory in HDFS file system..."
			CMD="hadoop fs -mkdir -p ${INPUT}"
			echo -e "${CMD}"
			${CMD}
	
			LOCAL_INPUT=file://${HOME}/examples/input/${CORPUS_NAME}
	
			echo -e "\nCopying input files to HDFS file system..."
			CMD="hadoop fs -cp -f ${LOCAL_INPUT}/*.* ${INPUT}"
			echo -e "${CMD}"
			${CMD}

			RUN_MODE="--runner hadoop"
			;;
		
		"NFS")
			INPUT_FILE_SYSTEM_TYPE=file://
			
			INPUT_BASE_DIRECTORY=${HOME}/examples	
			INPUT=${INPUT_BASE_DIRECTORY}/input/${CORPUS_NAME}
			
			INPUT_DIRECTORY_AUX=/share/${USER}/${CORPUS_NAME}
			INPUT_DIRECTORY=${INPUT_FILE_SYSTEM_TYPE}${INPUT_DIRECTORY_AUX}
			
			echo -e "\nCreating input shared diretory..."
			CMD="mkdir -p ${INPUT_DIRECTORY_AUX}"
			echo -e "\n${CMD}"
			${CMD}
			
			echo -e "\nCopying input files to shared diretory..."
			CMD="cp ${INPUT}/*.* ${INPUT_DIRECTORY_AUX}"
			echo -e "${CMD}"
			${CMD}

			RUN_MODE="--runner hadoop"
			;;		
		*)
			usage
	esac
fi


PYTHON_BIN=~/.local/share/pipx/venvs/mrjob/bin/python

PYTHON_SRC="./src"

JOB_FILE="wordCount.py"

JOB_FILE_FULL="${PYTHON_SRC}/${JOB_FILE}"

ARGS="${JOB_FILE_FULL} ${RUN_MODE} ${INPUT_DIRECTORY}"

echo "Running..."
CMD="${PYTHON_BIN} ${ARGS}"
echo ${CMD}

${CMD}
