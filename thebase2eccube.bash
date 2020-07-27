#!\bin/bash

export LC_ALL=en_US.UTF-8 # make sure awk/date etc behave consistently
program=$(basename $0 .bash)
argument=$1
timestamp=$(date -u "+%Y%m%d%H%M%S")

if [ $# -ne 1 ]
then
    echo "Usage: $0 products-export.thebase.sjis.csv"
    exit 1
fi

filename=$(basename "${argument}" .csv)
gawk="$(basename ${program}).awk"
imgdir="${filename}.${timestamp}"


original=${filename}.thebase.utf-8.csv
converted=${filename}.eccube.utf-8.csv
shiftjis=${filename}.eccube.sjis.csv

make    # compile the esc-csv preprocessor if needed

if [ ! -f ${gawk} ]
then
    echo "Error: Can't find awk processor program: ${gawk}"
    exit 1
fi

if iconv -f sjis -t utf-8 ${argument} -o ${original}
then
    if [ -d "${imgdir}" ]
    then
        echo "Warning: directory ${imgdir} already exists. Things may get overwritten"
    elif [ -e "${imgdir}" ]
    then
        echo "Error: a file by the name ${imgdir} already exists!"
        exit 1
    else
        mkdir ${imgdir}
    fi

    ./esc-csv ${original} | awk -f ${gawk} -o ${converted} 
    iconv -c -f utf-8 -t sjis ${converted} -o ${shiftjis}   # -c to not fail and just ignore proprietary unconvertable shift-jis

    echo "EC-CUBE CSV file for import, encoded in Shift-JIS, is: ${shiftjis}"
    echo "Images for import is in the directory: ${imgdir}"
fi