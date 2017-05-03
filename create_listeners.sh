#!/bin/bash

cd $(dirname $0)
source common.sh
doLog "Start"

LIST_FILE="car.list"

if [ ! -f $LIST_FILE ];then
	doLog 'car.list not exists'
	exit
fi

declare -A DISPATCH

NUM=0

doLog "Create listeners"
for CAR_ID in $(cat $LIST_FILE|awk -F"|" '{print $1}');do
	for USER in $(cat user.list|sed -r "s/\s+//g");do
		NAME=$(echo $USER|awk -F"|" '{print $1}')
		if [ "${DISPATCH[$NAME]}" != "" ];then
			continue;
		fi
		PASS=$(echo $USER|awk -F"|" '{print $2}')
		./user_login.sh $NAME $PASS
		./get_amount.sh $NAME
		FILE_NAME=$(ls cookies/|egrep "^$NAME"|tail -n 1)
		COOKIE_FILE="cookies/$FILE_NAME"
		./process_bid.sh $FILE_NAME $CAR_ID &
		doLog "Dispatch car=$CAR_ID to user=$NAME"
		DISPATCH[$NAME]=$CAR_ID
		NUM=$[$NUM + 1]
		break
	done
done

DISPATCH=()

for CAR_ID in $(tac $LIST_FILE|awk -F"|" '{print $1}');do
	if [ $NUM -ge 3 ];then
		break
	fi
	for USER in $(cat user.list|sed -r "s/\s+//g");do
		NAME=$(echo $USER|awk -F"|" '{print $1}')
		if [ "${DISPATCH[$NAME]}" != "" ];then
			continue;
		fi
		PASS=$(echo $USER|awk -F"|" '{print $2}')
		./user_login.sh $NAME $PASS
		./get_amount.sh $NAME
		FILE_NAME=$(ls cookies/|egrep "^$NAME"|tail -n 1)
		COOKIE_FILE="cookies/$FILE_NAME"
		./process_bid.sh $FILE_NAME $CAR_ID &
		doLog "Dispatch car=$CAR_ID to user=$NAME"
		DISPATCH[$NAME]=$CAR_ID
		NUM=$[$NUM + 1]
		break
	done
done

#doLog "Create auto ocr"
#./auto_ocr.sh &

doLog "Exit"
