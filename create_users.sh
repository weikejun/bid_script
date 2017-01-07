#!/bin/bash

SCRIPT=$(basename $0)
echo $(date "+%Y%m%d %H:%M:%S.%N")" $SCRIPT:Start"
cd $(dirname $0)

if [ ! -f car.list ];then
echo 'car.list not exists'
exit
fi

> sess.map

for CAR_ID in $(cat car.list|awk -F"|" '{print $1}');do
for USER in $(cat user.list);do
NAME=$(echo $USER|awk -F"|" '{print $1}')
PASS=$(echo $USER|awk -F"|" '{print $2}')
./user_login.sh $NAME $PASS
FILE_NAME=$(ls cookies/|grep $NAME|tail -n 1)
COOKIE_FILE="cookies/$FILE_NAME"
echo "$CAR_ID|$FILE_NAME" >> sess.map
done
done
