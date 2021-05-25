#!/bin/bash

err() { # a Google bash convention function
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

readonly SOURCE_DIR=$1
readonly DEST_DIR=$2

if (($# == 0)); then
  echo "Usage: ./script.sh <source directory> <destination directory>"
  exit 0
fi

if (($# > 2)); then
  err "Illegal number of arguments"
  exit 1
fi

if [[ ! -d ${DEST_DIR} ]]; then
  mkdir -p "${DEST_DIR}"
fi

if [[ ! -d ${SOURCE_DIR} ]]; then
  err 'Source directory does not exist'
  exit 3
fi


counter=0
for image in  "${SOURCE_DIR}"/*; do
  if file -i "${image}" | grep "$image":\ image > /dev/null 2>&1; then
    image_name=$(basename "${image%.*}")
    image_cleaned=${image_name//[\'\"\ ]/} #"'

    if find  "${DEST_DIR}"/"${image_cleaned}".png > /dev/null 2>&1; then
	    image_original=$image_cleaned
	    image_cleaned=${image_cleaned}$(find "${DEST_DIR}"/"${image_cleaned}"[0-9]*.png 2> /dev/null| wc -l )
            echo "WARNING : name ${image_original}.png was already taken, copied ${image} to destination as ${image_cleaned}.png"
    fi

    convert "${image}" -format "png" -fuzz 20%% -transparent White -resize 512x512 "${DEST_DIR}"/"${image_cleaned}".png 
    ((counter=counter+1))
  fi
done

echo "Succesfully copied and formatted ${counter} images from ${SOURCE_DIR} to ${DEST_DIR}"
