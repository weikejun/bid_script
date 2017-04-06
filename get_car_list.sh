#!/bin/bash

cd $(dirname $0)
source common.sh
doLog "Start"

DETECTOR="qwerty163"
LIST_FILE="car.list"

COOKIE_FILE="cookies/$(ls cookies/|grep $DETECTOR|tail -n 1)"
[ -f $COOKIE_FILE ] || ./user_login.sh $DETECTOR wkj12345678
COOKIE_FILE="cookies/$(ls cookies/|grep $DETECTOR|tail -n 1)"

doLog "TouZi.aspx request, get car's list"
curl -b "ItDoor=xiaolin;" -b $COOKIE_FILE 'http://www.zhongchoucar.com/Info/T493000657/Front/TouZi/TouZi.aspx?jc=zc' -H 'Pragma: no-cache' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: no-cache' -H 'Connection: keep-alive' --compressed -i > http/get_seed.http
doLog "TouZi.aspx response"

[ -f $LIST_FILE ] && rm $LIST_FILE
for uri in $(cat http/get_seed.http |grep -i "InsideTwo.aspx?Id"|sed -e "s/[<>]/\n/g"|grep "InsideTwo.aspx"|grep -e "^a href"|awk -F'"' '{print $2}'|uniq|xargs);do
	doLog "InsideTwo.aspx request, get car_id, uri=$uri"
	CARID=$(curl -b "ItDoor=xiaolin;" -b $COOKIE_FILE  "http://www.zhongchoucar.com$uri" -H 'Pragma: no-cache' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: http://www.zhongchoucar.com/Info/T493000657/Front/TouZi/TouZi.aspx?jc=zc' -H 'Connection: keep-alive' -H 'Cache-Control: no-cache' --compressed|grep "pro_title"|grep -e "id="|awk -F"'" '{print $4}')
	echo "$CARID|$uri" >> $LIST_FILE 
	doLog "InsideTwo.aspx response, car_id=$CARID"
done

chmod 666 $LIST_FILE

doLog "Exit"
