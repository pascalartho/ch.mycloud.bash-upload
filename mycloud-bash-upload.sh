#!/bin/bash

##########################################################################
# ch.mycloud.bash-upload - Upload files to mycloud.ch using bash
##########################################################################
# Copyright (C) 2016 Pascal Artho - All Rights Reserved
#
# Usage: ./mycloud-bash-upload.sh
#
# Preparation: set parameters
#
# Last revised: July 11, 2016
#
##########################################################################
# Parameters
##########################################################################
accessToken=""
localFolder="/home/ubuntu/mycloud/"
mycloudFolder="/Drive/bashUpload/"
fileFilter="*"
##########################################################################

# change current directory
cd "$localFolder"

# define progress counter
counter=0

# backup and modify internal field separator (IFS)
OIFS="$IFS"
IFS=$'\n'

# find and count files for upload
files=$(find -name "$fileFilter" -type f)
numberOfFiles=$(find -name "$fileFilter" -type f | wc -l)

# foreach file to upload
for f in $files
do
  echo "Start Upload $counter of $numberOfFiles"
  
  # get modification-date of file
  dateOfFile=$(LANG=en_us_88591 date -r "$f" +'%a, %d %b %Y %H:%M:%S')
  
  # define alternative filename variable for modifications
  file=$f
  # remove "./" in filename
  case "$file" in ./*) file=${file:2};; esac
  
  # Standard base64 encoder
  encodedString=$(echo -n "$mycloudFolder$file" | openssl base64 | tr -d '\n')
  
  # Remove any trailing '='
  encodedString=$(echo $encodedString | cut -f1 -d=)
  
  # 62nd char of encoding
  encodedString=${encodedString//'+'/'-'}
  
  # 63rd char of encoding
  encodedString=${encodedString//'/'/'_'}
  
  # Standard base64 decoder
  # decodedString=$(openssl base64 -d <<< $encodedString)
  
  # Debug information
  echo "Encoded Filename: $encodedString"
  echo "Filename:         $file"
  # echo "Decoded Filename: $decodedString"
  
  # Upload file using curl
  # if needed add "-k" or "--insecure" to perform "insecure" SSL connections and transfers
  curl -H "Content-Type: application/octet-stream" -H "Content-Disposition: attachment; modification-date=\"$dateOfFile GMT\"; filename=\"$mycloudFolder$file\"" -X "POST"  -T "$f" "https://storage.prod.mdl.swisscom.ch/object/?p=$encodedString&access_token=$accessToken" -g
  
  # increment progress counter
  counter=$((counter+1))
done

echo "Number of Uploaded Files: $counter"

# restore internal field separator (IFS)
IFS="$OIFS"
