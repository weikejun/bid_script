#!/bin/bash

cd $(dirname $0)
source common.sh
doLog "Start"

declare -A TRIGGER 
declare -A IDS

while [ 1 -eq 1 ];do
	NUM=$(ls tigger/|wc -l)
	if [ $NUM -eq 0 ];then
		continue;
	fi
	LEN=0
	EXPE=0
	for t in $(ls tigger/*);do
		ID=$(basename $t)
		TRIGGER[$LEN]=$(cat $t)
		IDS[$LEN]=$ID
		EXPE=$[$EXPE + ${TRIGGER[$LEN]}]
		LEN=$[$LEN + 1]
	done
	EXPE=$[$EXPE / $LEN]
	ITR=0
	while [ $ITR -lt $LEN ];do
		DT=$[${TRIGGER[$ITR]} - $EXPE]
		if [ $DT -lt -10 ];then
			doLog "Refine trigger, car="${IDS[$ITR]}", expe=$EXPE, trigger="${TRIGGER[$ITR]}
			echo $[$EXPE + 5] > tigger/${IDS[$ITR]}
		fi
		ITR=$[$ITR + 1]
	done
	sleep 10
done

doLog "Exit"
