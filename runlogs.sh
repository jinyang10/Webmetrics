#!/bin/bash

for f in weblog1.txt  weblog2.txt  weblog3.txt
do
	echo "Web metrics for log file $f"
	echo "===================="
	./webmetrics.sh $f
	echo
	echo
done
