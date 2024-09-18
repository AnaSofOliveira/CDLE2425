@echo off
echo off

call go-00-environment.cmd

echo Creating container...
	docker compose -f %ComposeFile% -p cdle-%SemesterStart%-%SemesterEnd%-v%Version% up -d

pause
