[![Build Status](https://travis-ci.org/d/bug-free-fortnight.svg?branch=develop)](https://travis-ci.org/d/bug-free-fortnight)

# Running tests for GPDB
This repository is a simple on-ramp to help contributors run tests (`installcheck`) for GPDB

## Prerequisites
1. Hack on your code, commit them locally
1. Assuming all your code repositories are checked out in the same directory
   locally (e.g. `~/workspace`). Specifically, the following repositories
   should be checked out locally (how else would you hack on them?)

   * [orca](https://github.com/greenplum-db/gporca)
   * [gp-xerces](https://github.com/greenplum-db/gp-xerces)
   * [gpdb](https://github.com/greenplum-db/gpdb)

## Just tell me how
1. `~/workspace/bug-free-fortnight/streamline-master/uber.bash`

## FAQ

1. Where's my container?

   We label the images and hence the containers. Try filtering like this:

   ```
   docker ps --filter label=io.github.d.uber-script
   ```

1. It's too noisy!

   We've fixed that by turning off most of the diagnostic output from Bash

1. It's too quiet!

   Set the `DEBUG` environment variable to reinstate debug output, e.g.
   `env DEBUG=1 streamline-master/uber.bash`

1. How do I set a GUC when running `installcheck`?

   Run with the `--interactive` flag first, e.g.
   ```
   streamline-43/uber.bash --interactive
   ```
   It will stop after starting the cluster, and you can follow the prompt to set
   any GUC before running `make installcheck`

1. ICG failed, but uber script deletes the container! How do I look at the diff
   against expected output?

   `regression.diffs` is always copied out when tests fail, try to get the most out of that.

1. uber script deletes the container when my tests fail! How do I attach to shit and debug?

   If you need to debug after the tests fail (so you know which regress test to
   re-run), run with the `--interactive-after-icg` flag
   ```
   streamline-43/uber.bash --interactive-after-icg
   ```
   It will run ICG, then stop in an interactive Bash prompt.

1. Shit's *SLOW*

   If you are using Docker for Mac, [don't](VMware_Fusion.md).

1. Shit don't work

   Please turn on debug output and attach the debug output when you ask for help

## License

See the [LICENSE](LICENSE) file for license rights and your freedom (GPL v3)
