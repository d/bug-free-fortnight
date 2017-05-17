[![Build Status](https://travis-ci.org/d/bug-free-fortnight.svg?branch=develop)](https://travis-ci.org/d/bug-free-fortnight)

# Running tests for GPDB
This repository is a simple on-ramp to help contributors run tests (`installcheck`) for GPDB

## Prerequisites
0. Hack on your code, commit them locally
0. Assuming all your code repositories are checked out in the same directory
   locally (e.g. `~/workspace`). Specifically, the following repositories
   should be checked out locally (how else would you hack on them?)
  0. [gpos](https://github.com/greenplum-db/gpos)
  0. [orca](https://github.com/greenplum-db/gporca)
  0. [gp-xerces](https://github.com/greenplum-db/gp-xerces)
  0. [gpdb](https://github.com/greenplum-db/gpdb)

## Just tell me how
0. `~/workspace/bug-free-fortnight/streamline-master/uber.bash`

## FAQ

0. It's too noisy!

  We've fixed that by turning off most of the diagnostic output from Bash

0. It's too quiet!

  Set the `DEBUG` environment variable to reinstate debug output, e.g.
  ```
  env DEBUG=1 streamline-master/uber.bash
  ```

0. It's still too quiet!

  ```
  env DEBUG=1 streamline-master/uber.bash --existential-angst
  ```
  This will output all the log information, including building GPORCA, etc.

0. How do I set a GUC when running `installcheck`?

  Run with the `--interactive` flag first, e.g.
  ```
  streamline-43/uber.bash --interactive
  ```
  It will stop after starting the cluster, and you can follow the prompt to set
  any GUC before running `make installcheck`

0. Shit's *SLOW*

  If you are using Docker for Mac, [don't](VMware_Fusion.md).

0. Shit don't work

  Please turn on debug output and attach the debug output when you ask for help

## License

See the [LICENSE](LICENSE) file for license rights and your freedom (GPL v3)
