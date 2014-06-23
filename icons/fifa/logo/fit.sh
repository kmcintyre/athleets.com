#!/bin/bash


for f in /home/kevin/scewpt/athleets/fifa/logo/*.svg
do
	echo `basename $f`	
	rsvg-convert `basename $f` -h 15 -f svg -o 15_`basename $f`
done