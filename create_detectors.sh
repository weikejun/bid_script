#!/bin/bash

SCRIPT=$(basename $0)
echo $(date "+%Y%m%d %H:%M:%S.%N")" $SCRIPT:Start"
cd $(dirname $0)

if [ ! -f car.list ];then
echo 'car.list not exists'
exit
fi

echo $(date "+%Y%m%d %H:%M:%S.%N")" $SCRIPT:Create detectors"
for CAR_ID in $(cat car.list|awk -F"|" '{print $1}');do
./detect.sh $CAR_ID &
done
echo $(date "+%Y%m%d %H:%M:%S.%N")" $SCRIPT:Exit"
