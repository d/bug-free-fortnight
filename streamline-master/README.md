## How to run `installcheck` locally ##

0. `docker build -t streamline-master ~/workspace/ci-infrastructure/streamline-master`
0. `docker run --rm -ti --volume ~/workspace:/workspace:ro streamline-master`
0. Now that you are inside, the following command will build everything and then run ICG
  ```
  [gpadmin@95ed490cb4c5 build]$ /workspace/ci-infrastructure/streamline-master/build_the_universe.bash
  ```
