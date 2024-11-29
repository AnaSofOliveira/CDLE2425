#!/bin/bash

LibraryPath="../NativeLibs"

JarFile="./target/Demo01-OpenCV-ExtractFramesFromVideo-2020.2021.SemInv.jar"

InputName=faces
#InputName=movie1
#InputName=pool

Input="../../../input/videos/${InputName}.mp4"
Output="../../../output/OpenCV/${InputName}"

mkdir -p ${Output}

Arguments="${Input} ${Output}"

JavaBin="${JAVA_HOME}/bin/java"

JavaOptions="-Djava.library.path=${LibraryPath}"

JavaAccessOptions="-Djavax.accessibility.assistive_technologies=java.lang.Object"

Command="${JavaBin} ${JavaOptions} ${JavaAccessOptions} -jar ${JarFile} ${Arguments}"

echo ""
echo "${Command}"
echo ""

${Command}

echo ""
