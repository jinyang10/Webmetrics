#!/bin/bash

#... do the checks/usage etc.

if [[ $# -ne 1 ]]
then
	echo Error!! pass a webserver log file as the argument.
	exit 1
fi

WEBLOGFILE=$1
if [[ ! -f $WEBLOGFILE ]]
then
	echo Error!! cannot access file $WEBLOGFILE 
	exit 2
fi

# find the number of requests from different browser types
echo "Number of requests per web browser"
for browser in Safari Firefox Chrome
do
	numrequests=$(grep $browser $WEBLOGFILE | wc -l)
	echo $browser,$numrequests
done
echo

# print a report with date and number of distinct users per day
echo "Number of distinct users per day"
# awk prints the "date-time" part, sed cleans it up to include only the actual date.
for day in $(awk '{ print $4 }' < $WEBLOGFILE | sed -e 's/^.//' -e 's/:.*//' | sort -u)
do
	# using grep get only lines for a particular day.
	# using awk print only the IP address
	# sort to make sure we pick up only unique IP addresses
	# use wc to count the number of distinct users
  numusers=$(grep $day $WEBLOGFILE | awk '{ print $1 }' | sort -u | wc -l)
  echo $day,$numusers
done
echo

# popular products requests
echo "Top 20 popular product requests"
# first awk searches for the proper "GET" pattern
# first expression of sed deletes the text in the line before the product id.
# second sed expression deletes the pattern after the product id.
# sort then orders them
# last awk keeps track of the number of times it has seen a product (remember it is sorted) and prints that information.
# last sort orders them based on the count first followed by product id
awk '/GET \/product\/[0-9]+\//'  < $WEBLOGFILE | sed -e 's/^.*GET \/product\///' -e 's/\/.*$//' | sort  | awk 'BEGIN { OFS=","; prevproduct=0; count=0; } { if ($1 != prevproduct) { if (count!=0) print prevproduct, count; prevproduct=$1; count=0; } count = count + 1 } END { print prevproduct, count }' | sort -t',' -n -r -k 2 -k 1 | head -20
