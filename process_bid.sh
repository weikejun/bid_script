#!/bin/bash

cd $(dirname $0)
source common.sh
doLog "Start"

if [ $# != 2 ];then
	echo "Usage: $SCRIPT [SESSION] [CAR_ID]"
	exit
fi

if [ ! -f cookies/$1 ];then
	echo "Session $1 not exit"
	exit
fi

COOKIE_FILE="cookies/$1"
URI=$(cat car.list|grep $2|awk -F"|" '{print $2}')
AMOUNT=$(cat amount/$(echo $1|awk -F"_" '{print $1}'))
REMOTE_ADDR="42.96.184.3"

if [ "$URI" == "" ];then
	echo "car $2 not in the list"
	exit
fi

if [ "$AMOUNT" == "" ];then
	echo "session $1 get money error"
	exit
fi

doLog "Waiting for tigger loop, session=$1, car_id=$2"
while [ 1 -eq 1 ];do
	if [ -f tigger/$2 ];then
		break
	fi
done
doLog "Tigger capture"

doLog "ContrastMoney_Handler.ashx request: touMoney=$AMOUNT&standardId=$2"
curl -b "ItDoor=xiaolin;" -b $COOKIE_FILE "http://$REMOTE_ADDR/Info/T493000657/Front/InsideTwo/Ajax/ContrastMoney_Handler.ashx" -H "Host: www.zhongchoucar.com" -H 'Pragma: no-cache' -H 'Origin: http://www.zhongchoucar.com' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Accept: */*' -H 'Cache-Control: no-cache' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' -H "Referer: http://www.zhongchoucar.com$URI" --data "touMoney=$AMOUNT&standardId=$2" --compressed -i -o "http/contrast_money_$1_$2"
RET=$(cat http/contrast_money_$1_$2|egrep "^[-0-9]+"|sed -r "s/\s+//g")
doLog "ContrastMoney_Handler.ashx response: $RET"

if [ "$(echo $RET|grep '&0')" == "" ];then
	doLog "Exit" 
	exit
fi

doLog "VerifyCodeNum.aspx request"
TIMESTAMP=$(date +%s)$(expr $(date +%N) / 1000000);
curl -b "ItDoor=xiaolin;" -b $COOKIE_FILE "http://$REMOTE_ADDR/Resource/Scripts/Common/VerifyCodeNum.aspx?time=$TIMESTAMP" -H "Host: www.zhongchoucar.com" -H 'Pragma: no-cache' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36' -H 'Accept: image/webp,*/*;q=0.8' -H "Referer: http://www.zhongchoucar.com$URI" -H 'Connection: keep-alive' -H 'Cache-Control: no-cache' --compressed -o "captcha/$1_$2.gif"
doLog "VerifyCodeNum.aspx response: captcha/$1_$2.gif create"

TIGGER=$(cat tigger/$2)
doLog "Waiting for submitting, tigger: $TIGGER"
while [ 1 -eq 1 ];do
	TIMESTAMP=$(date +%s)$(expr $(date +%N) / 1000000);
	if [ $TIMESTAMP -ge $TIGGER ];then
		if [ -f captcha/$1_$2.res ];then
			CAPTCHA=$(cat captcha/$1_$2.res|sed -r "s/\s+//g")
			doLog "ValSpeed.ashx request: captcha=$CAPTCHA"
			curl -b "ItDoor=xiaolin;" -b $COOKIE_FILE "http://$REMOTE_ADDR/Info/T493000657/Front/InsideTwo/Ajax/ValSpeed.ashx" -H 'Pragma: no-cache' -H 'Origin: http://www.zhongchoucar.com' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Accept: */*' -H 'Cache-Control: no-cache' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' -H "Referer: http://www.zhongchoucar.com$URI" --data "touMoney=$AMOUNT&payPwd=wkj12345678&imageYanMa=$CAPTCHA&standardId=$2&sensePwd=" --compressed -i -o "http/valspeed_$1_$2"
			doLog "ValSpeed.ashx response"
		fi
		break
	fi
done
doLog "Exit"
