# Using VMware Fusion for Greenplum Database development

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

0. Create your docker machine with Fusion:

  ```
  docker-machine create --driver vmwarefusion --vmwarefusion-disk-size 40960 --vmwarefusion-cpu-count -1 --vmwarefusion-memory-size 8192 default
  brew services start docker-machine
  ```

  The first command creates a VM named "default", using all CPUs available, and allocates 8 GiB of memory.
  The second command configures that VM to start on subsequent system boot.

  Note that you don't necessarily have to call the machine "default", but the second command (auto-start) will not work unless you name it "default"

0. In your shell session where you want to run Docker, if you see the following error:

  ```
  Cannot connect to the Docker daemon. Is the docker daemon running on this host?
  ```

  You can fix it by doing the following:

    * (Fish)

    ```
    eval (docker-machine env)
    ```

    * (Bash)

    ```
    eval "$(docker-machine env)"
    ```
