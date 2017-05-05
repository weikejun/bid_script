#!/bin/bash

cd $(dirname $0)
source common.sh
doLog "Start"

declare -A TRIGGER 

while [ 1 -eq 1 ];do
	NUM=$(ls tigger/|wc -l)
	if [ $NUM -eq 0 ];then
		continue;
	fi
	LEN=0
	MAX=0
	for t in $(ls tigger/*);do
		TRIGGER[$LEN]=$(cat $t)
		if [ $MAX -lt ${TRIGGER[$LEN]} ];then
			MAX=${TRIGGER[$LEN]}
		fi
		LEN=$[$LEN + 1]
	done
	for t in $(ls tigger/*);do
		echo -n $MAX > $t
	done
	sleep 1
done

doLog "Exit"
