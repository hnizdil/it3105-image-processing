#!/bin/bash

TRIES=5

function wget_file()
{
	wget \
		--tries 1 \
		--quiet \
		--output-document "$2" \
		"$1"

	if [ ! $? ]; then
		echo "Error when downloading file $1"
		exit 1
	fi
}

# URL of the file is the first argument
url="$1"

# We need at least URl
if [ -z "$url" ]; then
	echo "Usage: getvalid.sh url [destination_file]"
	exit 1
fi

# Destination file is either the second argument or we get it from the URL
if [ -z "$2" ]; then
	dest="$(basename "$url")"
else
	dest="$2"
fi

# We try to download the file
wget_file "$url" "$dest"

# Last file
last="$dest.v$RANDOM"

for i in "$(seq $TRIES)"; do
	# Move the actal file to the last file
	mv --force "$dest" "$last"

	# Download the file
	wget_file "$url" "$dest"

	# Check, if SHA1 hashes are the same
	res="$(
		sha1sum "$dest" "$last" \
			| uniq --check-chars 40 \
			| wc --lines
	)"

	# Hashes match, so we delete the last file and exit
	if [ "$res" -eq 1 ]; then
		rm --force "$last"
		exit 0
	fi
done

# If we're here, we haven't got valid file in $TRIES tries
echo "We haven't got valid file in $TRIES tries"
exit 1
