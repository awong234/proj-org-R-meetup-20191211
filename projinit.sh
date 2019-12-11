#!/bin/bash

# Make folders

if [ ! -d R/ ]
then
	mkdir R/
fi

if [ ! -d output/ ]
then
	mkdir output/
fi

if [ ! -d data/ ]
then
	mkdir data/
fi

if [ ! -d report/ ]
then
	mkdir report/
fi

if [ ! -d img/ ]
then
	mkdir img/
fi

# Rescuscitate renv

if [ ! -d renv/library ]
then
	Rscript -e "renv::restore()"
fi
