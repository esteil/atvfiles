#!/bin/sh

#
# plugins.awkwardtv.org Update Script
# Copyright (c) 2007 admin@awkwardtv.org
# GPL v2
# v1.0
#

# Check for correct number of arguments
if [  "x$5" == "x" ] ; then
        echo " "
        echo "plugins.awkwardtv.org Update Script"
        echo " "
        echo "First upload your file to a server, then run this script"
        echo "to update the (existing) entry on plugins.awkwardtv.org" 
        echo " "
        echo "Usage: $0 username password package version url"
        echo " "
        exit 1
fi

# Initialize variables
site=http://plugins.awkwardtv.org # no trailing slash needed
user=$1
pass=$2
package=$3
version=$4
url=$5

# Downlading enclosure
echo "Downloading $url"
enc=$(mktemp -t enc)
curl $url -o $enc || exit 1
echo ""

# Determining enclosure type
echo "Determining enclosure type"
enclosure_type=$(file -ib $enc)
echo $enclosure_type
echo ""

# Determining enclosure md5
echo "Determining enclosure md5"
enclosure_md5=$(md5 -q $enc)
echo $enclosure_md5
echo ""

# Determining enclosure length
echo "Determining enclosure length"
enclosure_length=$(ls -l $enc | cut -d " " -f 9)
echo $enclosure_length
echo ""

# Updating record
echo "Updating record"
cookies=$(mktemp -t awkcookies)

curl --silent --cookie-jar $cookies $header \
        --form "una=$user" \
        --form "upw=$pass" \
        $site/  -o /dev/null

curl --silent --cookie $cookies $header \
        --form "MM_update=updateform" \
        --form "p=$package" \
        --form "version=$version" \
        --form "enclosure_url=$url" \
        --form "enclosure_type=$enclosure_type" \
        --form "enclosure_md5=$enclosure_md5" \
        --form "enclosure_length=$enclosure_length" \
        $site/interface.php?p=$package |  grep "Update OK" || (echo "FAILED" ; exit 1) 
echo ""

rm -f $cookies
rm -f $enc