#!/bin/bash

cd $(dirname $0)
source common.sh
doLog "Start"

if [ $# != 1 ];then
	doLog "Usage: $SCRIPT [USERNAME]"
	exit
fi

USER=$1
COOKIE_FILE="cookies/$(ls cookies/|egrep "^$USER"|tail -n 1)"

if [ ! -f $COOKIE_FILE ];then
	doLog "User $USER not login"
	exit
fi

doLog "InsideTwo.aspx request, user=$USER get amount"
curl -b "ItDoor=xiaolin;" -b $COOKIE_FILE 'http://www.zhongchoucar.com/Info/T493000657/Front/InsideTwo/InsideTwo.aspx?Id=02C10D681C4EBE94' -H 'Pragma: no-cache' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Connection: keep-alive' -H 'Cache-Control: no-cache' --compressed -i|grep "person_balance"|sed -r "s#<[^<]+>|[^0-9\.]+##g"|awk '{printf "%.2f", ($1>50000?50000:$1)}' > amount/$USER
doLog "InsideTwo.aspx response, user=$USER amount=$(cat amount/$USER)"
doLog "Exit"
