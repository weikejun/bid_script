#!/bin/bash

cd $(dirname $0)
source common.sh
doLog "Start"

if [ ! -f car.list ];then
	doLog 'car.list not exists'
	exit
fi

CAR_NO=$(echo $(cat car.list|wc -l)|awk '{srand();print (int(rand()*10))%$1;}')
IND=-1

doLog "Create listeners"
for CAR_ID in $(cat car.list|awk -F"|" '{print $1}');do
	IND=$[$IND + 1]
	if [ $IND -ne $CAR_NO ];then
		continue;
	fi
	for USER in $(cat user.list|sed -r "s/\s+//g");do
		NAME=$(echo $USER|awk -F"|" '{print $1}')
		PASS=$(echo $USER|awk -F"|" '{print $2}')
		./user_login.sh $NAME $PASS
		./get_amount.sh $NAME
		FILE_NAME=$(ls cookies/|grep $NAME|tail -n 1)
		COOKIE_FILE="cookies/$FILE_NAME"
		./process_bid.sh $FILE_NAME $CAR_ID &
	done
done

#doLog "Create auto ocr"
#./auto_ocr.sh &

doLog "Exit"
