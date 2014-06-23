#!/bin/bash

for f in /home/kevin/scewpt/athleets/nba/logo/*.svg
do
	echo `basename $f`	
	rsvg-convert `basename $f` -h 23 -f svg -o 20_`basename $f`
done
