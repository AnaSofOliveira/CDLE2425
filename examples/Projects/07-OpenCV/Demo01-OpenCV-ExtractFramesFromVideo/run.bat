@echo off
echo off

set LibraryPath=..\NativeLibs

set JarFile=.\target\Demo01-OpenCV-ExtractFramesFromVideo-2020.2021.SemInv.jar

rem set InputName=faces
rem set InputName=movie1
set InputName=pool

set Input=..\..\..\input\videos\%InputName%.mp4

set Output=..\..\..\output\OpenCV\%InputName%

mkdir %Output%

set Arguments=%Input% %Output%

set JavaBin=%JAVA_HOME%\bin\java

set JavaOptions=-Djava.util.Arrays.useLegacyMergeSort=true -Djava.library.path=%LibraryPath%

set Command=%JavaBin% %JavaOptions% -jar %JarFile% %Arguments%

echo.
echo %Command%
echo.
%Command%
echo.

pause