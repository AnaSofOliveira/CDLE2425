* Access to the Linux system:
	+ User: `usermr`
	+ Password: `m2preduce`

* Configure MapReduce environment:

	+ Execute the following scripts:
		- Windows:
			- `go-00-environment.cmd`
			- `go-01-BuildImage.cmd`
			- `go-02-CreateContainer.cmd`

		- Linux:
			- `go-00-environment.sh`
			- `go-01-BuildImage.sh`
			- `go-02-CreateContainer.sh`

	+ After executing each script, open a SSH session inside the container hadoop-opencv-2024-2025:
		- `./install-hadoop/00-a-java-install.sh`
		- `./install-hadoop/00-b-ant-install.sh`
		- `./install-hadoop/00-c-maven-install.sh`
		- `./install-hadoop/00-d-ssh-env.sh`
		
		- `./installHadoop.sh` (execute this command from the `install-hadoop` directory)
		- `./11-hadoop-InitUser.sh usermr` (execute this command from the `install-hadoop` directory)

	+ Execute the following scripts (in a new terminal):
		- `sudo chown -R usermr:hadoop examples/`
		- `sudo chmod -R o-w examples/`
		- `sudo chown usermr:hadoop /home/usermr`

* After starting the Docker container, it is necessary to execute the following script (inside the `install-hadoop` directory):
	+ `07-hadoopPseudoDistributed-Start.sh`
