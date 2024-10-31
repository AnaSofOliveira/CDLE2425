#!/bin/bash


source ./usage.sh

LOCAL_FILE_SYSTEM_TYPE=file://
LOCAL_BASE_DIRECTORY=${HOME}/examples

HDFS_FILE_SYSTEM_TYPE=hdfs://
HDFS_BASE_DIRECTORY=/user/${USER}

NUMBER_DISPLAY_LINES=15

# CORPUS_NAME=gutenberg-mixed
CORPUS_NAME=gutenberg-small

INPUT=${LOCAL_BASE_DIRECTORY}/input/${CORPUS_NAME}
OUTPUT=${HDFS_BASE_DIRECTORY}/output/${CORPUS_NAME}

INPUT_DIRECTORY=${LOCAL_FILE_SYSTEM_TYPE}${INPUT}
OUTPUT_DIRECTORY=${HDFS_FILE_SYSTEM_TYPE}${OUTPUT}

echo "Removing previous output from HDFS..."

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




ARGS="${INPUT_DIRECTORY} ${OUTPUT_DIRECTORY}"

echo "Exporting classpath..."
export HADOOP_CLASSPATH=${JAR_FILE}

echo "HADOOP_CLASSPATH=${HADOOP_CLASSPATH}"

echo "Running..."
CMD="hadoop ${MAIN_CLASS} ${ARGS}"
echo ${CMD}

${CMD}