# Using a remove VM on AWS

0. (Optional) Uninstall Docker for Mac
  0. Click the whale in your tray, choose "Preferences..."
  0. Choose "Uninstall / Reset" tab
  0. Click "Uninstall" and follow the wizard

0. Now try running `docker`, if you see the following error message:

  ```
  $ docker
  bash: docker: command not found
  ```

  Then install docker, docker-machine, and docker-compose:

  ```
  brew install docker-compose
  ```

0. Create your docker machine on AWS:
  Follow the guide on https://docs.docker.com/machine/drivers/aws/#options for security options etc.

  ```
	docker-machine create --driver amazonec2 --amazonec2-instance-type c4.large --amazonec2-root-size 40 icg-$(whoami)
  ```

	The first command creates a EC2 VM of type c4.large and 40 GB root drive.
	Remember to use the appropriate account credentials if they're not already in
	`~/.aws/`.
	Refer to the various instance types & their costs [here](https://aws.amazon.com/ec2/pricing/on-demand/).

	Remember to stop/delete the VM when you don't need it for long periods using the AWS console.


0. In your shell session where you want to run Docker, if you see the following error:

  ```
  Cannot connect to the Docker daemon. Is the docker daemon running on this host?
  ```

  You can fix it by doing the following:

    * (Fish)

    ```
    eval (docker-machine env icg-$(whoami))
    ```

    * (Bash)

    ```
    eval "$(docker-machine icg-$(whoami))"
    ```
