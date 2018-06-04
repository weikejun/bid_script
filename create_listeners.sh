#!/bin/bash

cd $(dirname $0)
source common.sh
doLog "Start"

LIST_FILE="car.list"

if [ ! -f $LIST_FILE ];then
	doLog "$LIST_FILE not exists"
	exit
fi

declare -A DISPATCH


doLog "Create listeners"
for USER in $(cat user.list|sed -r "s/\s+//g");do
    read NAME PASS PAYPASS < <(echo $USER|awk -F'|' '{print $1,$2,$3}')
    # 登录取余额
    ./user_login.sh $NAME $PASS
    ./get_amount.sh $NAME
done

for DETECTOR in $(cat detector.list|sed -r "s/\s+//g");do
    read USER CAR_SEQ AMOUNT < <(echo $DETECTOR|awk -F'|' '{print $1,$2,$3}')
    doLog "Dispatching car=$CAR_SEQ to user=$USER"
    CAR_FOUND=$(grep $CAR_SEQ car.list)
    if [ "$CAR_FOUND" == "" ];then
        doLog "Fail, car seq '$CAR_SEQ' not found in $LIST_FILE"
        continue
    fi
    read PASS PAYPASS < <(grep "^$USER|" user.list|sed -r "s/\s+//g"|awk -F'|' '{print $2,$3}')
    if [ "$PASS" == "" ];then
        doLog "Fail, user '$USER' not found in user.list"
        continue
    fi
    FILE_NAME=$(ls cookies/|egrep "^$USER"|tail -n 1)
    ./process_bid.sh "$FILE_NAME" "$CAR_SEQ" "$PAYPASS" "$AMOUNT" &
    doLog "Success"
done
#ITR=0
#CAR_LEN=0
#USR_LEN=0
#for USER in $(cat user.list|sed -r "s/\s+//g");do
#	CAR_LEN=0
#	for CAR_ID in $(cat $LIST_FILE|head -n 3|awk -F"|" '{print $1}');do
#		DISPATCH[$ITR]=$USER"|"$CAR_ID
#		ITR=$[$ITR + 1]
#		CAR_LEN=$[$CAR_LEN + 1]
#	done
#	USR_LEN=$[$USR_LEN + 1]
#done
#CAR_ITR=0
#USR_ITR=0
#NUM=0
#MAX_NUM=2
#while [ $CAR_ITR -lt $CAR_LEN ] && [ $NUM -lt $MAX_NUM ];do
#	DIFF=$CAR_ITR
#	USR_ITR=0
#	while [ $USR_ITR -lt $USR_LEN ] && [ $NUM -lt $MAX_NUM ];do
#		ITR=$[$USR_ITR * $CAR_LEN]
#		ITR=$[$ITR + $DIFF]
#		read NAME PASS PAYPASS CAR_ID < <(echo ${DISPATCH[$ITR]}|awk -F'|' '{print $1,$2,$3,$4}')
#		./user_login.sh $NAME $PASS
#		./get_amount.sh $NAME
#		FILE_NAME=$(ls cookies/|egrep "^$NAME"|tail -n 1)
#		COOKIE_FILE="cookies/$FILE_NAME"
#		./process_bid.sh $FILE_NAME $CAR_ID $PAYPASS &
#		doLog "Dispatch car=$CAR_ID to user=$NAME"
#		USR_ITR=$[$USR_ITR + 1]
#		DIFF=$[$DIFF + 1]
#		DIFF=$[$DIFF % $CAR_LEN]
#		NUM=$[$NUM + 1]
#	done
#	CAR_ITR=$[$CAR_ITR + 1]
#done

#doLog "Create auto ocr"
#./auto_ocr.sh &

doLog "Exit"
