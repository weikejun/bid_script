#!/bin/bash

cd $(dirname $0)
source common.sh
doLog "Start"

if [ ! -f car.list ];then
	doLog 'car.list not exists'
	exit
fi

doLog "Create detectors"
for CAR_ID in $(cat car.list|awk -F"|" '{print $1}');do
	./detect.sh $CAR_ID &
done
doLog "Exit"
