#!/bin/bash


source ./usage.sh

LOCAL_FILE_SYSTEM_TYPE=file://
LOCAL_BASE_DIRECTORY=${HOME}/examples

HDFS_FILE_SYSTEM_TYPE=hdfs://
HDFS_BASE_DIRECTORY=/user/${USER}

NUMBER_DISPLAY_LINES=15

# CORPUS_NAME=gutenberg-mixed
CORPUS_NAME=gutenberg-small

INPUT=${HDFS_BASE_DIRECTORY}/input/${CORPUS_NAME}
OUTPUT=${LOCAL_BASE_DIRECTORY}/output/${CORPUS_NAME}

INPUT_DIRECTORY=${HDFS_FILE_SYSTEM_TYPE}${INPUT}
OUTPUT_DIRECTORY=${LOCAL_FILE_SYSTEM_TYPE}${OUTPUT}

echo "Removing previous output from HDFS..."

echo -e "\nRemoving previous output..."
CMD="rm -rf ${OUTPUT}"
echo -e "\n${CMD}"
${CMD}


ARGS="${INPUT_DIRECTORY} ${OUTPUT_DIRECTORY}"

echo "Exporting classpath..."
export HADOOP_CLASSPATH=${JAR_FILE}

echo "HADOOP_CLASSPATH=${HADOOP_CLASSPATH}"

echo "Copiar arquivos do HDFS para o local..."
echo "Running..."
CMD="time hadoop fs -copyToLocal ${ARGS}"
echo ${CMD}

${CMD}