@echo off
echo off

call go-00-environment.cmd

echo Removing old data...
docker builder prune --force

echo Creating CDLE image for Winter Semester %SemesterStart%/%SemesterEnd% (Version %Version%)...

cd Docker
 	docker build -t cdle.ubuntu.%SemesterStart%.%SemesterEnd%.v%Version% .
cd ..

pause
