#!/bin/bash
# Download latest database backup
printf "\nDownload latest database backup from acquia cloud using acli\n======\n\n"
if [ $# -lt 2 ]
  then
    printf "Usage: $0 <environmentId> <databaseName> [<destination folder>]\n\n"
    exit 1
fi

info=$(acli api:environments:database-backup-list $1 $2 | jq '.[0] | {id:.id, date:.completed_at}')
download_id=$(jq -r '.id' <<< "$info")
download_date=$(jq -r '.date' <<< "$info")

echo " | id:$download_id date:$download_date"

#Format date for file name
IFS='T' read -ra SLICE <<< "$download_date"
download_date=${SLICE[0]}

# echo $download_id
# echo $download_date


url=$(acli api:environments:database-backup-download $1 $2 $download_id | jq -r '.url')
echo " | $url"

# Check if direcory if specified
filePath="$2-$download_id-$download_date.sql.gz"

if [ $# -eq 3 ]
  then
    filePath="$3/$filePath"
fi

echo " | $filePath"
echo " | download process started...."
curl ${url} -o $filePath
echo " | unzip ...."
gunzip -f $filePath
echo " Process completed !"
