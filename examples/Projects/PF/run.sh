#!/bin/bash

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
			MAIN_ARGS="local"
			;;
		"hdfs")
			MAIN_ARGS="HDFS"
			;;
		"nfs")
			MAIN_ARGS="NFS"
			;;
		*)
			usage
	esac
fi

PYTHON_BIN=python3

MAIN_FILE="src/main.py"

ARGS="${MAIN_FILE} ${MAIN_ARGS}"

echo "Running main..."
CMD="${PYTHON_BIN} ${ARGS}"
echo ${CMD}

${CMD}
