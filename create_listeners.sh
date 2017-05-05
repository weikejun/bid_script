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


doLog "Create listeners"
ITR=0
CAR_LEN=0
USR_LEN=0
for USER in $(cat user.list|sed -r "s/\s+//g");do
	CAR_LEN=0
	for CAR_ID in $(cat $LIST_FILE|awk -F"|" '{print $1}');do
		DISPATCH[$ITR]=$USER"|"$CAR_ID
		ITR=$[$ITR + 1]
		CAR_LEN=$[$CAR_LEN + 1]
	done
	USR_LEN=$[$USR_LEN + 1]
done
CAR_ITR=0
USR_ITR=0
NUM=0
MAX_NUM=3
while [ $CAR_ITR -lt $CAR_LEN ] && [ $NUM -lt $MAX_NUM ];do
	DIFF=$CAR_ITR
	USR_ITR=0
	while [ $USR_ITR -lt $USR_LEN ] && [ $NUM -lt $MAX_NUM ];do
		ITR=$[$USR_ITR * $CAR_LEN]
		ITR=$[$ITR + $DIFF]
		read NAME PASS CAR_ID < <(echo ${DISPATCH[$ITR]}|awk -F'|' '{print $1,$2,$3}')
		./user_login.sh $NAME $PASS
		./get_amount.sh $NAME
		FILE_NAME=$(ls cookies/|egrep "^$NAME"|tail -n 1)
		COOKIE_FILE="cookies/$FILE_NAME"
		./process_bid.sh $FILE_NAME $CAR_ID &
		doLog "Dispatch car=$CAR_ID to user=$NAME"
		USR_ITR=$[$USR_ITR + 1]
		DIFF=$[$DIFF + 1]
		DIFF=$[$DIFF % $CAR_LEN]
		NUM=$[$NUM + 1]
	done
	CAR_ITR=$[$CAR_ITR + 1]
done

#doLog "Create auto ocr"
#./auto_ocr.sh &

doLog "Exit"
