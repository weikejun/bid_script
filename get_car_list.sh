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
curl -b "ItDoor=xiaolin;" -b $COOKIE_FILE 'http://che.zhongchoucar.com/Info/T493000657/Front/TouZi/TouZi.aspx?jc=zc' -H 'Pragma: no-cache' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: no-cache' -H 'Connection: keep-alive' --compressed -i > http/get_seed.http
doLog "TouZi.aspx response"

if [ -f $LIST_FILE ]; then 
	LASTMO=$(date -d "$(stat $LIST_FILE|grep -i "modify"|sed -r "s/modify:\s+//ig")" +%s)
	LASTMO=$(($LASTMO + 30))
	if [ $(date +%s) -gt $LASTMO ];then
		CMD="rm -f $LIST_FILE"
		echo $CMD
		eval $CMD
	fi
fi
for uri in $(cat http/get_seed.http |grep -i "InsideTwo.aspx?Id"|sed -e "s/[<>]/\n/g"|grep "InsideTwo.aspx"|grep -e "^a href"|awk -F'"' '{print $2}'|uniq|xargs);do
	HASHID=$(echo $uri|awk -F'=' '{print $2}')
	if [ -f $LIST_FILE ]; then
		EX=$(grep $HASHID $LIST_FILE|wc -l)
		if [ "$EX" -ge 1 ];then
			doLog "InsideTwo.aspx response, uri=$uri has exist"
			continue
		fi
	fi
	doLog "InsideTwo.aspx request, get car_id, uri=$uri"
	curl -b "ItDoor=xiaolin;" -b $COOKIE_FILE  "http://che.zhongchoucar.com$uri" -H 'Pragma: no-cache' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: http://che.zhongchoucar.com/Info/T493000657/Front/TouZi/TouZi.aspx?jc=zc' -H 'Connection: keep-alive' -H 'Cache-Control: no-cache' --compressed > http/car_$HASHID
	CARID=$(cat http/car_$HASHID |grep pro_title|sed -r "s/\s+//g"|grep -Po "(?<=pro_title'id=')[0-9]+")
    CARTL=$(cat http/car_$HASHID |grep pro_title|sed -r "s/\s+//g"|grep -Po "(?<=融车网)[^<]+")
	MONEY=$(cat http/car_$HASHID |grep pro_target|sed -r "s/\s+|,//g"|grep -Po "(?<=:)[0-9\.]+")
    PROCS=$(cat http/car_$HASHID |grep "众筹人次"|sed -r "s/\s+|,//g"|grep -Po "(?<=>)[0-9]+[^%]+")
	doLog "InsideTwo.aspx response, car_id=$CARID"
    KEY=$(curl -b "ItDoor=xiaolin;" -b $COOKIE_FILE  "http://che.zhongchoucar.com/Info/T493000657/Front/InsideTwo/Ajax/GetPageDataHandler.ashx" -H 'Pragma: no-cache' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: http://che.zhongchoucar.com/Info/T493000657/Front/TouZi/TouZi.aspx?jc=zc' -H 'Connection: keep-alive' -H 'Cache-Control: no-cache' --data "id=tab_cardetails&standId=$CARID" --compressed | grep -Po "(?<=收购价格)[0-9]+")
    if [ "$KEY" == '' ];then
        KEY="PRICE=0"
    else
        KEY="PRICE=$KEY"0000
    fi
	if [ $CARID != "" ];then
		echo "$CARID|$HASHID|$MONEY|$PROCS|$CARTL|$KEY" >> $LIST_FILE 
	fi
done

chmod 666 $LIST_FILE

doLog "Exit"
