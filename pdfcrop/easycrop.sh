#!/bin/bash

pdfpath=$1
# filename=${pdfpath##*/}
# dirpath=${pdfpath%/*}
filename=$(basename ${pdfpath})
dirpath=$(dirname ${pdfpath})
remotedir='/home/hadoop/lql/'
remotepath=${remotedir}${filename}
# echo ${pdfpath} ${filename} ${dirpath} ${remotedir} ${remotepath}
# echo "~/bin/pdfcrop ${remotepath} ${remotepath}"

scp ${pdfpath} hadoop@n19:${remotedir}
ssh hadoop@n19 "~/bin/pdfcrop ${remotepath} ${remotepath}"
scp hadoop@n19:${remotepath} ${dirpath}