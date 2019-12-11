# Make this presentation!

This presentation is fully reproducible (or ought to be!)

It uses a combination of `git`, `make`, and `renv` to bootstrap packages and
create all the outputs defined in the `makefile`

## Usage 

`./projinit.sh` will make a bunch of folders (if they don't exist), and it will
call `renv::restore()` to get all of the packages in order.

`make all` will run through the data loading through the transformations,
analyses, reports, and finally will build the presentation given at the
Cleveland R Meetup (2019-12-11).

```shell
./projinit.sh
make all
```
