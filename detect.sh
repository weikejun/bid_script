#!/bin/bash

cd $(dirname $0)
source common.sh
doLog "Start"

if [ $# != 1 ];then
	doLog "Usage: $SCRIPT [CAR_ID]"
	exit
fi

TMFILE="http/detect_start_$1.http"
REMOTE_ADDR=$(nslookup www.zhongchoucar.com|grep Address|grep -v "#53"|awk '{print $2}')

doLog "GetDateTime loop start, car_id=$1"
COUNTDOWN_LAST=-1
TIGGER_MIN=1999999999999
while [ 1 -eq 1 ];do
	NS=$(date +%s%N)
	START_TIME=${NS:0:13}
	curl "http://$REMOTE_ADDR/Info/T493000657/Front/InsideTwo/InsideTwo.aspx/GetDateTime" -H 'Host: www.zhongchoucar.com' -H 'Pragma: no-cache' -H 'Origin: http://www.zhongchoucar.com' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36' -H 'Content-Type: application/json; charset=UTF-8' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Cache-Control: no-cache' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' -w "\ntotal elapse="%{time_total}"\n" --data-binary "{\"sid\":\"$1\"}" --compressed -i > $TMFILE

	FLAG=$(cat $TMFILE|grep -i "HTTP/1.1 200")

	if [ "$FLAG" != "" ];then
		COUNTDOWN=$(awk -F'"' '/^{.+}$/{print $4*1000}' $TMFILE)
		if [ $COUNTDOWN -eq 0 ];then
			continue
		fi
		ADJUST=$(awk -F'=' '/^total elapse/{print $2*1000}' $TMFILE)
		if [ $ADJUST -gt 50 ];then
			doLog "GetDateTime elapse=$ADJUST too long, car_id=$1, retry"
			continue
		fi
		TIGGER=$(echo $START_TIME $COUNTDOWN $ADJUST|awk '{printf "%.0f", $1+$2+$3*0-140}')
		if [ $TIGGER -lt $TIGGER_MIN ];then
			TIGGER_MIN=$TIGGER
			echo $TIGGER_MIN > tigger/$1
			sleep 0.5
		fi
		if [ $COUNTDOWN_LAST -eq -1 ];then
			COUNTDOWN_LAST=$COUNTDOWN
			doLog "GetDateTime tigger create, car_id=$1, countdown=$COUNTDOWN, adjust=$ADJUST, tigger_time=$TIGGER_MIN"
			continue;
		else
			if [ $COUNTDOWN -lt 13000 ];then
				doLog "GetDateTime tigger refine done, car_id=$1, countdown=$COUNTDOWN, adjust=$ADJUST, tigger_time=$TIGGER_MIN"
				break;
			else
				COUNTDOWN_LAST=$COUNTDOWN
				continue;
			fi
		fi
	else
		[ -f tigger/$1 ] && rm tigger/$1
		sleep 0.3
	fi

done
doLog "GetDateTime loop end"
doLog "Exit"
