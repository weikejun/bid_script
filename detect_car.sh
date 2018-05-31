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
LIST_FILE="car.list"
LOCAL_IP=$(/sbin/ifconfig eth1|grep inet|sed "s/:/ /g"|awk '{print $3}')
NOW_DATE=$(date +%Y%m%d)

while [ 1 -eq 1 ];do
	if [ -f $LIST_FILE ];then # 发标探测通知
		NOTIFY="NO"
		for CAR in $(cat $LIST_FILE); do
            read CAR_SEQ CAR_ID MONEY PROCS < <(echo $CAR|awk -F'|' '{print $1,$2,$3,$4}')
			# 出现筹资进度20%的车通知抢标 
            if [ "$PROCS" == "20.00" ]; then
			# if [ "$PROCS" == "100.00" ]; then
                NOTIFY="YES"
				break
			fi
		done	
		if [ "$NOTIFY" == "NO" ]; then
			continue
		fi
		FOUND=$(date -d "$(stat $LIST_FILE|grep -i "modify"|sed -r "s/modify:\s+//ig")" +%s)
        TTS=$[3600 - $FOUND % 3600 - 60]
		START=$[$FOUND + $TTS]
		echo $START > $TRIGGER_FILE
		FOUND_DATE=$(date +"%Y%m%d %H:%M:%S" -d @$FOUND)
		START_DATE=$(date +"%Y%m%d %H:%M:%S" -d @$START)
		MESSAGE="Car.list has created in $FOUND_DATE, robot will start in $START_DATE"
		doLog "$MESSAGE"

        # 邮件通知抢标既将开始
        MAIL_LIST="78250611@qq.com"
		if [ "$MAIL_LIST" != "" ];then
			echo $MESSAGE | mail -s "[Rongche notify]Cars found - from $LOCAL_IP" $MAIL_LIST
		fi

        # 等待准点前60秒启动监听进程
        sleep $TTS
        if [ "$MAIL_LIST" != "" ];then
            MAIL=""
            for AMOUNT_FILE in $(ls amount/);do
                MAIL="$MAIL $AMOUNT_FILE="$(cat amount/$AMOUNT_FILE)
            done
            echo "car.list ready, $(cat $LIST_FILE|wc -l) cars; "$MAIL | mail -s "[Rongche notify]Ready - from $LOCAL_IP" $MAIL_LIST
        fi

		./create_listeners.sh >> log/$NOW_DATE # 创建抢标监听进程

        # 准点前30秒启动探测进程
        sleep 30
		./create_detectors.sh >> log/$NOW_DATE # 创建开始探测进程

        # 通知抢标结果
		sleep 60 
        ./notify_response.sh

        # 1800秒后重新开始探测
        sleep 1800
	fi
	sleep 10
done

doLog "Exit"
