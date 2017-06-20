#!/bin/bash

cd $(dirname $0)
source common.sh
doLog "Start"

SELF=$(basename $0)
EXIST=$(ps -ef|grep $SELF|egrep -v "grep|vim|\b$$\b|\b$PPID\b"|wc -l)
if [ $EXIST -ge 1 ];then
	doLog "Exit"
	exit
fi

TRIGGER_FILE="tigger/car"
SLEEP_TIME=1440
LOCAL_IP=$(/sbin/ifconfig eth1|grep inet|sed "s/:/ /g"|awk '{print $3}')

while [ 1 -eq 1 ];do
	if [ -f $TRIGGER_FILE ];then # 开始执行抢标脚本
		NOW_DATE=$(date +%Y%m%d)
		TRIGGER=$(cat $TRIGGER_FILE)
		SLEEP_TIME=$[$TRIGGER]
		NOW_TIME=$(date +%s)
		SLEEP_TIME=$[$SLEEP_TIME - $NOW_TIME]
		source user_map.sh
		
		doLog "Trigger exist, sleep"

		sleep $SLEEP_TIME
		./set_user_list.sh >> log/$NOW_DATE # 生成抢标账户

		sleep 120
		./create_listeners.sh >> log/$NOW_DATE # 创建抢标监听进程

		sleep 30
		./create_detectors.sh >> log/$NOW_DATE # 创建开始探测进程

		sleep 3600
		continue
	elif [ -f car.list ];then # 发标探测通知
		FOUND=$(date -d "$(stat car.list|grep -i "modify"|sed -r "s/modify:\s+//ig")" +%s)
		START=$[$FOUND + 1440]
		echo $START > $TRIGGER_FILE
		FOUND_DATE=$(date +"%Y%m%d %H:%M:%S" -d @$FOUND)
		START_DATE=$(date +"%Y%m%d %H:%M:%S" -d @$START)
		MESSAGE="Car.list has created in $FOUND_DATE, robot will start in $START_DATE"
		doLog "$MESSAGE"
		if [ "$MAIL_LIST" != "" ];then
			echo $MESSAGE | mail -s "[Rongche notify]Cars found - from $LOCAL_IP" $MAIL_LIST
		fi
		continue
	fi
	sleep 10
done

doLog "Exit"
