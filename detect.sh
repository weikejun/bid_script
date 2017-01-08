#!/bin/bash

cd $(dirname $0)
source common.sh
doLog "Start"

if [ $# != 1 ];then
	echo "Usage: $SCRIPT [CAR_ID]"
	exit
fi

TMFILE="http/detect_start_$1.http"

doLog "GetDateTime loop start, car_id=$1"
while [ 1 -eq 1 ];do
	START_TIME=$(date +%s)$(expr $(date +%N) / 1000000);
	curl 'http://42.96.184.3/Info/T493000657/Front/InsideTwo/InsideTwo.aspx/GetDateTime' -H 'Host: www.zhongchoucar.com' -H 'Pragma: no-cache' -H 'Origin: http://www.zhongchoucar.com' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36' -H 'Content-Type: application/json; charset=UTF-8' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Cache-Control: no-cache' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' -w "\ntotal elapse="%{time_total}"\n" --data-binary "{\"sid\":\"$1\"}" --compressed -i > $TMFILE

	FLAG=$(cat $TMFILE|grep -i "HTTP/1.1 200")

	if [ "$FLAG" != "" ];then
		COUNTDOWN=$(awk -F'"' '/^{.+}$/{print $4}' $TMFILE)
		ADJUST=$(awk -F'=' '/^total elapse/{print $2}' $TMFILE)
		TIGGER=$(echo $START_TIME $COUNTDOWN $ADJUST|awk '{printf "%.0f", $1+$2*1000-$3*1000}')
		echo $TIGGER > tigger/$1
		doLog "GetDateTime tigger create, tigger_time=$TIGGER"
		break
	else
		[ -f tigger/$1 ] && rm tigger/$1
	fi

done
doLog "GetDateTime loop end"
doLog "Exit"
