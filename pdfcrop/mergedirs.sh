#!/bin/bash


# source="/Users/qiliangli/Downloads/source"
# des="/Users/qiliangli/Downloads/target"

source=$1
des=$2
find "$source" -d -type f -not -name .DS_Store -exec mv {} "$des" \;