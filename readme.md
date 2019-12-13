# High-level overview

* Reproducible projects are *good projects*, and are probably designed well.
  Reproducibility is thus an objective of good projects.
* Tools such as `git`, `GNU make`, `renv` assist in reproducibility, and induce
  ideas of *intentionality*, *codification*, and *explicitness* naturally --
  just by using them.
* These ideas are fundamental to good project design, and reproducibility.

## Presentation

The presentation is located in the `compiled` branch. If you clone this repo
with no intention to run through the `make` example and just want to see the
outputs, switch to that branch after cloning:

```
git clone https://github.com/awong234/proj-org-R-meetup-20191211.git
git checkout compiled
```

# Make this presentation!

This presentation is fully reproducible (or ought to be!)

It uses a combination of `git`, `make`, and `renv` to bootstrap packages and
create all the outputs defined in the `makefile`.

There also is a little example analysis to demonstrate the ideas behind make.

1. Census data were obtained regarding citizen voting proportions for
   presidential elections ( `scripts/import_voting_rate_data.R` )
2. The data are in a `.xlsx` format, and so some transformations need to be
   done to get it into a usable flat format (`scripts/transform.R`). 
3. Some regressions are performed on the data (`scripts/analyze.R`)
4. The model results are formatted with brief commentary in R Markdown into a
   report.
5. The presentation is compiled from and Rmd file
   (`pres/aw-project-organization-201912.Rmd`), depending on a ggplot graphic
   created in the `img/` folder (`img/proj-graphic.R`)

View the presentation through any browser with the HTML file in
`pres/aw-project-organization-201912.html` once compiled, or directly in the
`compiled` branch.

## Usage 

From the master branch, run the following:

```shell
./projinit.sh
make all
```

`./projinit.sh` will make a bunch of folders (if they don't exist), and it will
call `renv::restore()` to get all of the packages in order.

`make all` will run through the data loading through the transformations,
analyses, reports, and finally will build the presentation given at the
Cleveland R Meetup (2019-12-11).

