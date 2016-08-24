## There are 21 Tricks to Speed Up 4.3_STABLE Development. I'm gonna tell you 6 ##

0. Prerequisites:
  0. You have gpdb4 checked out on your computer.
  0. You have all the submodules updated on your host: `git submodule update --init --recursive`
0. `docker build -t rofl ~/workspace/bug-free-fortnight/streamline-43 -f ~/workspace/bug-free-fortnight/streamline-43/Dockerfile.gpdb4`
0. `docker run --rm -ti --volume ~/workspace/gpdb4:/gpdb_src:ro rofl`
0. Now you're inside that container: run this
  ```
  git clone /gpdb_src /build/gpdb4
  ```
0. Change your working directory to the checkout inside the container:
  ```
  cd /build/gpdb4
  ```
0. Now make all the objects available to git submodules:
  ```
  rsync -r /gpdb_src/.git/modules .git
  ```
0. Now this: `git submodule update --init --recursive`
0. don't forget the set the compiler and sync dependencies

  ```
  cd gpAux
  source /opt/gcc_env.sh
  make sync_tools
  ```
0. Important hack:
  ```
  ln -sf ~/gpdb4/gpAux/ext/rhel5_x86_64/python-2.6.2 /opt
  ```
0. You've been waiting for the next command:
  ```
  make GPROOT=/build/install dist
  ```
0. In order to spin up the demo cluster, you'll need to set (read: pollute) your environment
  ```
  source /build/install/greenplum-db-devel/greenplum_path.sh
  ```
0. Now make your demo cluster: `make -C gpdemo`
