#!/bin/bash

cd $(dirname $0)
source common.sh
doLog "Start"

if [ ! -f car.list ];then
	doLog 'car.list not exists'
	exit
fi

doLog "Create detectors"
#for CAR_ID in $(cat car.list|head -n 3|awk -F"|" '{print $1}');do
for CAR_ID in $(cat detector.list|awk -F"|" '{print $2}'|uniq);do
    CAR_FOUND=$(grep $CAR_ID car.list)
    # 防止错误探测
    if [ "$CAR_FOUND" != "" ];then
        ./detect.sh $CAR_ID &
    fi
done

#doLog "Create trigger refine"
#./refine_trigger.sh &

doLog "Exit"
