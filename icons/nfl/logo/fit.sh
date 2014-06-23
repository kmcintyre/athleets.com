#!/bin/bash
for f in /home/kevin/scewpt/athleets/nfl/logo/*.svg
do
	echo `basename $f`	
	rsvg-convert `basename $f` -h 20 -f svg -o 20_`basename $f`
done