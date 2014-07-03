#!/bin/bash
for f in *.svg
do
	echo `basename $f`	 
	rsvg-convert `basename $f` -h 20 -f svg -o '../logo/'`basename $f`
done