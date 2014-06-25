#!/bin/bash

function doResize {
 find *.svg -exec inkscape -f {} --verb=FitCanvasToDrawing --verb=FileSave --verb=FileClose \;
}
doResize