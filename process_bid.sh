#!/bin/bash

cd $(dirname $0)
source common.sh
doLog "Start"

if [ $# != 2 ];then
	doLog "Usage: $SCRIPT [SESSION] [CAR_ID]"
	exit
fi

if [ ! -f cookies/$1 ];then
	doLog "Session $1 not exit"
	exit
fi

COOKIE_FILE="cookies/$1"
URI=$(cat car.list|grep $2|awk -F"|" '{print $2}')
AMOUNT=$(cat amount/$(echo $1|awk -F"_" '{print $1}'))
REMOTE_ADDR=$(nslookup www.zhongchoucar.com|grep Address|grep -v "#53"|awk '{print $2}')

if [ "$URI" == "" ];then
	doLog "Car $2 not in the list"
	exit
fi

if [ "$AMOUNT" == "" ];then
	doLog "Session $1 get money error"
	exit
fi

if [ "$AMOUNT" == "0.00" ];then
	doLog "Session $1 has not enough money"
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
doLog "ContrastMoney_Handler.ashx response=$RET, session=$1, car_id=$2"

if [ "$(echo $RET|grep '&0')" == "" ];then
	doLog "Exit" 
	exit
fi

doLog "VerifyCodeNum.aspx request"
NS=$(date +%s%N)
TIMESTAMP=${NS:0:13}
curl -b "ItDoor=xiaolin;" -b $COOKIE_FILE "http://$REMOTE_ADDR/Resource/Scripts/Common/VerifyCodeNum.aspx?time=$TIMESTAMP" -H "Host: www.zhongchoucar.com" -H 'Pragma: no-cache' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36' -H 'Accept: image/webp,*/*;q=0.8' -H "Referer: http://www.zhongchoucar.com$URI" -H 'Connection: keep-alive' -H 'Cache-Control: no-cache' --compressed -o "captcha/$1_$2.gif"
doLog "VerifyCodeNum.aspx response: captcha/$1_$2.gif create"

doLog "Waiting for captcha input, session=$1, car_id=$2"
while [ 1 -eq 1 ];do
	convert captcha/$1_$2.gif -fuzz 40% -transparent white -alpha extract -negate -resize 180x75 /tmp/$1_$2.jpg > /dev/null
	[ -f /tmp/$1_$2.jpg ] && tesseract /tmp/$1_$2.jpg /tmp/$1_$2 -l eng -psm 6 > /dev/null
	[ -f /tmp/$1_$2.txt ] && eval "echo|awk '{printf \"%d\n\", $(cat /tmp/$1_$2.txt|sed -r 's/[^0-9\+\-]//g')}'" > captcha/$1_$2.ocr
	if [ -f captcha/$1_$2.res ];then
		CAPTCHA=$(cat captcha/$1_$2.res|sed -r "s/\s+//g")
		break
	fi
done
doLog "Captcha input ok, code=$CAPTCHA, session=$1, car_id=$2"

TIGGER=$(cat tigger/$2)
doLog "Waiting for submitting, tigger=$TIGGER, session=$1, car_id=$2"
while [ 1 -eq 1 ];do
	NS=$(date +%s%N)
	TIMESTAMP=${NS:0:13}
	if [ $TIMESTAMP -ge $TIGGER ];then
		doLog "ValSpeed.ashx request: captcha=$CAPTCHA"
		curl -b "ItDoor=xiaolin;" -b $COOKIE_FILE "http://$REMOTE_ADDR/Info/T493000657/Front/InsideTwo/Ajax/ValSpeed.ashx" -H 'Host: www.zhongchoucar.com' -H 'Pragma: no-cache' -H 'Origin: http://www.zhongchoucar.com' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Accept: */*' -H 'Cache-Control: no-cache' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' -H "Referer: http://www.zhongchoucar.com$URI" --data "touMoney=$AMOUNT&payPwd=wkj12345678&imageYanMa=$CAPTCHA&standardId=$2&sensePwd=" --compressed -i -o "http/valspeed_$1_$2"
		RET=$(cat http/valspeed_$1_$2|egrep "^[-0-9]+"|sed -r "s/\s+//g")
		doLog "ValSpeed.ashx response=$RET, session=$1, car_id=$2"
		break
	fi
done
doLog "Exit"
