#!/bin/bash

SPARK_Bin=spark-submit
Class=org.apache.spark.examples.SparkPi

DriverMemory=4g
ExecutorMemory=2g
ExecutorCores=2

JarFile=/work/hadoop/spark/examples/jars/spark-examples_2.12-3.5.3.jar

Class_OPTS="--class ${Class}"

Cluster_OPTS="--master yarn --deploy-mode cluster"

Executer_OPTS="--driver-memory ${DriverMemory} --executor-memory ${ExecutorMemory} --executor-cores ${ExecutorCores}"

Args=10

CMD="${SPARK_Bin} ${Class_OPTS} ${Cluster_OPTS} ${Executer_OPTS} ${JarFile} ${Args}"

echo "Running..."
echo ${CMD}

${CMD}

