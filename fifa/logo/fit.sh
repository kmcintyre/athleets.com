#!/bin/bash


for f in *.svg
do
	echo `basename $f`	
	rsvg-convert `basename $f` -h 18 -f svg -o 18_`basename $f`
done