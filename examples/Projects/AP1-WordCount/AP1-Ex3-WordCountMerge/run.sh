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
	exit
}

if [[ $# -lt 2 ]]; then
	usage
else
	case "$1" in
		"local")
			FILE_SYSTEM_TYPE=file://
			BASE_DIRECTORY=${HOME}/examples
			;;
		
		"HDFS")
			FILE_SYSTEM_TYPE=hdfs://
			BASE_DIRECTORY=/user/${USER}
			;;
		
		*)
			usage
	esac
	NUMBER_REDUCERS=$2
fi

source ./usage.sh

NUMBER_DISPLAY_LINES=15

# COMPRESSION_CODEC=org.apache.hadoop.io.compress.GzipCodec
# COMPRESSION_CODEC = org.apache.hadoop.io.compress.BZip2Codec


############################################################################################################
# 												First corpus                                              #
############################################################################################################


CORPUS_NAME_day1=gutenberg-mixed

INPUT_day1=${BASE_DIRECTORY}/input/${CORPUS_NAME_day1}
OUTPUT_day1=${BASE_DIRECTORY}/output/day1/${CORPUS_NAME_day1}

INPUT_DIRECTORY_day1=${FILE_SYSTEM_TYPE}${INPUT_day1}
OUTPUT_DIRECTORY_day1=${FILE_SYSTEM_TYPE}${OUTPUT_day1}


echo "Removing previous output..."

echo "File System Type: ${FILE_SYSTEM_TYPE}"

if [ "${FILE_SYSTEM_TYPE}" == "file://" ]; then
	echo -e "\nRemoving previous output..."
	CMD="rm -rf ${OUTPUT_day1}"
	echo "Output directory being removed from local: ${OUTPUT_day1}"
	echo -e "\n${CMD}"
	${CMD}
else
	echo -e "\nCreating input directory in HDFS file system..."
	CMD="hadoop fs -mkdir -p ${INPUT_day1}"
	echo -e "${CMD}"
	${CMD}
	
	LOCAL_INPUT_day1=file://${HOME}/examples/input/${CORPUS_NAME_day1}
	
	echo -e "\nCopying input files to HDFS file system..."
	CMD="hadoop fs -cp -f ${LOCAL_INPUT_day1}/*.* ${INPUT_day1}"
	echo -e "${CMD}"
	${CMD}
	
	echo -e "\nRemoving previous output..."
	CMD="hadoop fs -rm -f -r ${OUTPUT_day1}"
	echo "Output directory being removed from HDFS: ${OUTPUT_day1}"
	echo -e "\n${CMD}"
	${CMD}
fi

echo "NUMBER_REDUCERS=$NUMBER_REDUCERS"
# echo "CODEC=$COMPRESSION_CODEC"
ARGS="${INPUT_DIRECTORY_day1} ${OUTPUT_DIRECTORY_day1} ${NUMBER_REDUCERS}"

# echo "Exporting classpath..."
# export HADOOP_CLASSPATH=${JAR_FILE}

# echo "HADOOP_CLASSPATH=${HADOOP_CLASSPATH}"

echo "Running..."

#hadoop jar $EXTERNAL_JAR_PATH package.name.ClassName /input/path /output/path
CMD="hadoop jar /home/usermr/examples/Projects/AP1-WordCount/AP1-Ex2b-WordCountReducers/target/AP1-Ex2b-WordCountReducers-2020.2021.SemInv.jar cdle.wordcount.mr.WordCountApplication ${ARGS}"
# CMD="hadoop ${MAIN_CLASS} ${ARGS}"
echo ${CMD}

${CMD}

OUT_FILES_day1=`hadoop fs -ls ${OUTPUT_DIRECTORY_day1}/part-r-* | tr -s ' ' | cut -d' ' -f8`

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


############################################################################################################
# 												Second corpus                                              #
############################################################################################################

CORPUS_NAME_day2=gutenberg-small
INPUT_day2=${BASE_DIRECTORY}/input/${CORPUS_NAME_day2}
OUTPUT_day2=${BASE_DIRECTORY}/output/day_2/${CORPUS_NAME_day2}

INPUT_DIRECTORY_day2=${FILE_SYSTEM_TYPE}${INPUT_day2}
OUTPUT_DIRECTORY_day2=${FILE_SYSTEM_TYPE}${OUTPUT_day2}



echo "Processing second corpus..."

echo "Removing previous output for second corpus..."

if [ "${FILE_SYSTEM_TYPE}" == "file://" ]; then
	echo -e "\nRemoving previous output..."
	CMD="rm -rf ${OUTPUT_day2}"
	echo -e "\n${CMD}"
	${CMD}
else
	echo -e "\nCreating input directory in HDFS file system for second corpus..."
	CMD="hadoop fs -mkdir -p ${INPUT_day2}"
	echo -e "${CMD}"
	${CMD}
	
	LOCAL_INPUT_day2=file://${HOME}/examples/input/${CORPUS_NAME_day2}
	
	echo -e "\nCopying input files to HDFS file system for second corpus..."
	CMD="hadoop fs -cp -f ${LOCAL_INPUT_day2}/*.* ${INPUT_day2}"
	echo -e "${CMD}"
	${CMD}
	
	echo -e "\nRemoving previous output for second corpus..."
	CMD="hadoop fs -rm -f -r ${OUTPUT_day2}"
	echo -e "\n${CMD}"
	${CMD}
fi

echo "Running for second corpus..."
ARGS="${INPUT_DIRECTORY_day2} ${OUTPUT_DIRECTORY_day2} ${NUMBER_REDUCERS}"

CMD="hadoop jar /home/usermr/examples/Projects/AP1-WordCount/AP1-Ex2b-WordCountReducers/target/AP1-Ex2b-WordCountReducers-2020.2021.SemInv.jar cdle.wordcount.mr.WordCountApplication ${ARGS}"
# CMD="hadoop ${MAIN_CLASS} ${ARGS}"
echo ${CMD}

${CMD}

OUT_FILES_day2=`hadoop fs -ls ${OUTPUT_day2}/part-r-* | tr -s ' ' | cut -d' ' -f8`

for file in ${OUT_FILES_day2}; do

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




############################################################################################################
# 												   Merge	                                               #
############################################################################################################

echo "Merging outputs of previous jobs..."

MERGED_OUTPUT=${BASE_DIRECTORY}/output/merged
MERGED_OUTPUT_DIRECTORY=${FILE_SYSTEM_TYPE}${MERGED_OUTPUT}

echo "Removing previous merged output..."
if [ "${FILE_SYSTEM_TYPE}" == "file://" ]; then
	CMD="rm -rf ${MERGED_OUTPUT}"
	echo -e "\n${CMD}"
	${CMD}
else
	CMD="hadoop fs -rm -f -r ${MERGED_OUTPUT}"
	echo -e "\n${CMD}"
	${CMD}
fi

echo "Creating merged output directory..."
if [ "${FILE_SYSTEM_TYPE}" == "file://" ]; then
	CMD="mkdir -p ${MERGED_OUTPUT}"
	echo -e "\n${CMD}"
	${CMD}
else
	CMD="hadoop fs -mkdir -p ${MERGED_OUTPUT}"
	echo -e "\n${CMD}"
	${CMD}
fi

echo "Copying outputs to merged directory..."
if [ "${FILE_SYSTEM_TYPE}" == "file://" ]; then
	CMD="cp ${OUTPUT_day1}/part-r-* ${MERGED_OUTPUT}/"
	echo -e "\n${CMD}"
	${CMD}
	CMD="cp ${OUTPUT_day2}/part-r-* ${MERGED_OUTPUT}/"
	echo -e "\n${CMD}"
	${CMD}
else
	CMD="hadoop fs -cp ${OUTPUT_day1}/part-r-* ${MERGED_OUTPUT}/"
	echo -e "\n${CMD}"
	${CMD}
	CMD="hadoop fs -cp ${OUTPUT_day2}/part-r-* ${MERGED_OUTPUT}/"
	echo -e "\n${CMD}"
	${CMD}
fi

echo "Merged output directory: ${MERGED_OUTPUT_DIRECTORY}"