#!/bin/bash

CORPUS_NAME=outlierDetection
OUTPUT_FILE_NAME=filterOutlier


CFG="-conf ${CONFIG_FILE_FULL}"
for conf in "$@"; do
	CFG="${CFG} ${conf}"
done

echo -e "Configuration: ${CFG}"

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


function remove_output() {
	local output=$1
	CMD="hadoop fs -rm -f -r ${output}"
	echo -e "\n${CMD}"
	${CMD}
}

function remove_output_local() {
	local output=$1
	CMD="rm -rf ${output}"
	echo -e "\n${CMD}"
	${CMD}
}

function create_dir() {
	local dir=$1
	CMD="hadoop fs -mkdir -p ${dir}"
	echo -e "${CMD}"
	${CMD}
}

function copy_file() {
	local path1=$1
	local path2=$2
	CMD="hadoop fs -cp -f ${path1} ${path2}"
	echo -e "${CMD}"
	${CMD}
}

function copy_file_local() {
	local path1=$1
	local path2=$2
	CMD="hadoop fs -copyToLocal -f ${path1} ${path2}"
	echo -e "${CMD}"
	${CMD}
}

if [[ $# -lt 1 ]]; then
	usage
else
	case "$1" in
		"local")
			FILE_SYSTEM_TYPE=file://
			BASE_DIRECTORY=${HOME}/examples
			
			INPUT=${BASE_DIRECTORY}/output/${CORPUS_NAME}
			OUTPUT=${BASE_DIRECTORY}/output/${OUTPUT_FILE_NAME}

			INPUT_DIRECTORY=${FILE_SYSTEM_TYPE}${INPUT}
			OUTPUT_DIRECTORY=${OUTPUT}

			echo -e "\nRemoving previous output..."
			remove_output_local "${OUTPUT}"

			RUN_MODE="--runner local"
			;;
		
		"HDFS")
			FILE_SYSTEM_TYPE=hdfs://
			BASE_DIRECTORY=/user/${USER}
			
			INPUT=${BASE_DIRECTORY}/output/${CORPUS_NAME}
			OUTPUT=${BASE_DIRECTORY}/output/${OUTPUT_FILE_NAME}

			INPUT_DIRECTORY=${FILE_SYSTEM_TYPE}${INPUT}
			OUTPUT_DIRECTORY=${FILE_SYSTEM_TYPE}${OUTPUT}

			LOCAL_OUTPUT_DIR="${HOME}/examples/output"
			echo -e "\nRemoving previous local output..."
			remove_output_local "${LOCAL_OUTPUT_DIR}/${OUTPUT_FILE_NAME}"
			
			echo -e "\nCreating input directory in HDFS file system..."
			create_dir "${INPUT}"
	
			LOCAL_INPUT=file://${HOME}/examples/output/${CORPUS_NAME}
	
			echo -e "\nCopying input files to HDFS file system..."
			copy_file "${LOCAL_INPUT}/*.*" "${INPUT}"

			echo -e "\nRemoving previous output..."
			remove_output "${OUTPUT}"

			RUN_MODE="--runner hadoop"
			;;
		
		"NFS")
			INPUT_FILE_SYSTEM_TYPE=file://
			
			INPUT_BASE_DIRECTORY=${HOME}/examples	
			INPUT=${INPUT_BASE_DIRECTORY}/input/${CORPUS_NAME}
			
			INPUT_DIRECTORY_AUX=/share/${USER}/${CORPUS_NAME}
			INPUT_DIRECTORY=${INPUT_FILE_SYSTEM_TYPE}${INPUT_DIRECTORY_AUX}
			
			OUTPUT_BASE_DIRECTORY=/user/${USER}
			OUTPUT=${OUTPUT_BASE_DIRECTORY}/output/${OUTPUT_FILE_NAME}
			OUTPUT_DIRECTORY=${OUTPUT} #${OUTPUT_FILE_SYSTEM_TYPE}${OUTPUT}

			echo -e "\nCreating input shared diretory..."
			CMD="mkdir -p ${INPUT_DIRECTORY_AUX}"
			echo -e "\n${CMD}"
			${CMD}
			
			echo -e "\nCopying input files to shared diretory..."
			CMD="cp ${INPUT}/*.* ${INPUT_DIRECTORY_AUX}"
			echo -e "${CMD}"
			${CMD}

			echo -e "\nRemoving previous output..."
			remove_output "${OUTPUT}"

			RUN_MODE="--runner hadoop"
			;;		
		*)
			usage
	esac
fi



PYTHON_BIN=python3

PYTHON_SRC="src/showOutliers"

JOB_FILE="${PYTHON_SRC}/ShowOutlier.py"

CONFIG_FILE="${PYTHON_SRC}/config.json"

UTILS="${PYTHON_SRC}/utils.py"
PROTOCOL="${PYTHON_SRC}/protocol.py"
BIOSPY_UTILS="src/utils/biospy_utils.py"

FILES="${UTILS},${PROTOCOL},${BIOSPY_UTILS}"

LOG_LEVEL=DEBUG

ARGS="${JOB_FILE} ${RUN_MODE}
	--files ${FILES}
	--output-dir ${OUTPUT_DIRECTORY}  
	--conf-path ${CONFIG_FILE}
	--log-level ${LOG_LEVEL}
	${INPUT_DIRECTORY} "
	
echo "Running..."
CMD=" ${PYTHON_BIN} ${ARGS}"
echo ${CMD}

${CMD}

# apos terminar job final 
if [[ "$1" = "HDFS" ]]; then
	echo -e "\nCopying output files on HDFS file system to local output..."
	copy_file_local "${OUTPUT_DIRECTORY}" "${LOCAL_OUTPUT_DIR}"

	echo -e "Output copied to local directory: ${LOCAL_OUTPUT_DIR}"
fi



IMAGES_FILE="src/generate_plots/plots_images.py"

echo "Running main..."
CMD="${PYTHON_BIN} ${IMAGES_FILE} ${LOCAL_OUTPUT_DIR}/${OUTPUT_FILE_NAME}/part-00000.gz ${LOCAL_OUTPUT_DIR}/${OUTPUT_FILE_NAME}"
echo ${CMD}
${CMD}
: <<'EOF'
# Display the contents of all .seq files in the output directory
echo -e "\nContents of the .seq files in ${OUTPUT_DIRECTORY}:"
for SEQ_FILE in $(hadoop fs -ls ${OUTPUT_DIRECTORY} | awk '{print $8}'); do
	echo -e "\nContents of ${SEQ_FILE}:"
	hadoop fs -text ${SEQ_FILE}
done


#-o ${OUTPUT_DIRECTORY}

EOF