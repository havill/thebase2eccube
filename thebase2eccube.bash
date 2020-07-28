#!/bin/bash

export LC_ALL=en_US.UTF-8 # make sure awk etc behave consistently

if [ $# -ne 2 ]
then
    echo "Usage: $0 ec-cube-home.dir thebase-products-export.sjis.csv" > /dev/stderr
    exit 1
fi
if [ ! -d $1 -o ! -f $2 ]
then
    echo "1st argument should be the EC-CUBE 4.x home directory" > /dev/stderr
    echo "2nd argument should be a CSV file exported by THE BASE" > /dev/stderr
    exit 1
fi

program=$(basename $0 .bash)
eccube_home=$(realpath $1)/html/upload/save_image/  # EC-CUBE 4.x dir structure
thebase_csv=$(realpath $2)
charset=shift_jis

preawk="$(basename ${program})-pre"
gawk="$(basename ${program}).awk"

preawk_path=$(realpath ${preawk})
gawk_path=$(realpath ${gawk})
csv_path=${PWD}/$(basename "${thebase_csv}" .csv).eccube.csv

make ${preawk}  # compile the esc-csv preprocessor if needed

cd ${eccube_home}    # make sure the downloaded images are deposited directly in ec-cube's imgdir
iconv -c -f ${charset} -t utf-8 ${thebase_csv} | ${preawk_path} | awk -f ${gawk_path} | iconv -c -f utf-8 -t ${charset} -o ${csv_path}