# One step to run `installcheck`

## Prerequisites
0. Assuming all your code repositories are checked out in the same directory
   locally (e.g. `~/workspace`). Specifically, the following repositories
   should be checked out locally (how else would you hack on them?)
  0. [gpos](https://github.com/greenplum-db/gpos)
  0. [orca](https://github.com/greenplum-db/gporca)
  0. [gp-xerces](https://github.com/greenplum-db/gp-xerces)
  0. gpdb4

    You should have all the submodules updated on your host:
    `git submodule update --init --recursive`

## Just tell me how
0. export the credentials in your SHELL
0. `~/workspace/bug-free-fortnight/streamline-43/uber.bash`

## License

See the [LICENSE](../LICENSE) file for license rights and your freedom (GPL v3)
