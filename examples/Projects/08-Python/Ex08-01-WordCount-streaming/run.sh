#!/bin/bash

NUMBER_REDUCERS=2
NUMBER_DISPLAY_LINES=15

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
			OUTPUT=${BASE_DIRECTORY}/output/${CORPUS_NAME}

			INPUT_DIRECTORY=${FILE_SYSTEM_TYPE}${INPUT}
			OUTPUT_DIRECTORY=${FILE_SYSTEM_TYPE}${OUTPUT}
			
			echo -e "\nRemoving previous output..."
			CMD="rm -rf ${OUTPUT}"
			echo -e "\n${CMD}"
			${CMD}
			
			;;
		
		"HDFS")
			FILE_SYSTEM_TYPE=hdfs://
			BASE_DIRECTORY=/user/${USER}
			
			INPUT=${BASE_DIRECTORY}/input/${CORPUS_NAME}
			OUTPUT=${BASE_DIRECTORY}/output/${CORPUS_NAME}

			INPUT_DIRECTORY=${FILE_SYSTEM_TYPE}${INPUT}
			OUTPUT_DIRECTORY=${FILE_SYSTEM_TYPE}${OUTPUT}
			
			echo -e "\nCreating input directory in HDFS file system..."
			CMD="hadoop fs -mkdir -p ${INPUT}"
			echo -e "${CMD}"
			${CMD}
	
			LOCAL_INPUT=file://${HOME}/examples/input/${CORPUS_NAME}
	
			echo -e "\nCopying input files to HDFS file system..."
			CMD="hadoop fs -cp -f ${LOCAL_INPUT}/*.* ${INPUT}"
			echo -e "${CMD}"
			${CMD}
	
			echo -e "\nRemoving previous output..."
			CMD="hadoop fs -rm -f -r ${OUTPUT}"
			echo -e "\n${CMD}"
			${CMD}
			;;
		
		"NFS")
			INPUT_FILE_SYSTEM_TYPE=file://
			OUTPUT_FILE_SYSTEM_TYPE=hdfs://
			
			INPUT_BASE_DIRECTORY=${HOME}/examples	
			INPUT=${INPUT_BASE_DIRECTORY}/input/${CORPUS_NAME}
			
			INPUT_DIRECTORY_AUX=/share/${USER}/${CORPUS_NAME}
			INPUT_DIRECTORY=${INPUT_FILE_SYSTEM_TYPE}${INPUT_DIRECTORY_AUX}
			
			OUTPUT_BASE_DIRECTORY=/user/${USER}
			OUTPUT=${OUTPUT_BASE_DIRECTORY}/output/${CORPUS_NAME}
			OUTPUT_DIRECTORY=${OUTPUT_FILE_SYSTEM_TYPE}${OUTPUT}

			echo -e "\nCreating input shared diretory..."
			CMD="mkdir -p ${INPUT_DIRECTORY_AUX}"
			echo -e "\n${CMD}"
			${CMD}
			
			echo -e "\nCopying input files to shared diretory..."
			CMD="cp ${INPUT}/*.* ${INPUT_DIRECTORY_AUX}"
			echo -e "${CMD}"
			${CMD}

			echo -e "\nRemoving previous output..."
			CMD="hadoop fs -rm -f -r ${OUTPUT}"
			echo -e "\n${CMD}"
			${CMD}
			;;		
		*)
			usage
	esac
fi

PYTHON_SRC="./src"

JOB_MAPPER_FILE="mapper.py"
JOB_REDUCER_FILE="reducer.py"

JOB_MAPPER_CMD="-mapper ${JOB_MAPPER_FILE}"
JOB_REDUCER_CMD="-reducer ${JOB_REDUCER_FILE}"

JOB_CMDS="${JOB_MAPPER_CMD} ${JOB_REDUCER_CMD}"

JOB_FILES="-files ${PYTHON_SRC}/${JOB_MAPPER_FILE},${PYTHON_SRC}/${JOB_REDUCER_FILE}"

NUMBER_REDUCERS_TASKS="-numReduceTasks ${NUMBER_REDUCERS}"

INPUT="-input ${INPUT_DIRECTORY}"
OUTPUT="-output ${OUTPUT_DIRECTORY}"

JAR_FILE=${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-streaming-3.3.1.jar

ARGS="${JOB_FILES} ${JOB_CMDS} ${INPUT} ${OUTPUT} ${NUMBER_REDUCERS_TASKS}"

echo "Running..."
CMD="hadoop jar ${JAR_FILE} ${ARGS}"
echo ${CMD}

${CMD}

OUT_FILES=`hadoop fs -ls ${OUTPUT_DIRECTORY}/part-* | tr -s ' ' | cut -d' ' -f8`

for file in ${OUT_FILES}; do

	echo ""
		
	echo "Result sorted by key - MapReduce defaults - (first ${NUMBER_DISPLAY_LINES} lines)"
	CMD="hadoop fs -text ${file} 2>/dev/null | head -n ${NUMBER_DISPLAY_LINES}"
	echo ${CMD}
	
	hadoop fs -text ${file} 2>/dev/null | head -n ${NUMBER_DISPLAY_LINES}
	
	echo ""
	echo "Result sorted (by value) using the linux sort command"
	CMD="hadoop fs -text ${file} 2>/dev/null | sort -k 2,2 -n -r | head -n ${NUMBER_DISPLAY_LINES}"
	echo ${CMD}
	
	hadoop fs -text ${file} 2>/dev/null | sort -k 2,2 -n -r | head -n ${NUMBER_DISPLAY_LINES}
done
