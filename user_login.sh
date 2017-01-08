#!/bin/bash

cd $(dirname $0)
source common.sh
doLog "Start"

if [ $# != 2 ];then
echo "Usage: $(basename $0) [USERNAME] [PASSWORD]"
exit
fi

USER=$1
PASS=$2
COOKIE_FILE="cookies/$USER""_$(date +%s)"
HTTP_FILE="http/user_login_$USER.http"

doLog "Login_Handler.ashx request, User $USER login"
curl -b "ItDoor=xiaolin;" -D $COOKIE_FILE 'http://www.zhongchoucar.com/Info/T493000657/Front/AjaxValedate/Login_Handler.ashx' -H 'Pragma: no-cache' -H 'Origin: http://www.zhongchoucar.com' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Accept: */*' -H 'Cache-Control: no-cache' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' -H "Cookie: ItDoor=xiaolin" -H 'Referer: http://www.zhongchoucar.com/index.aspx' --data "username=$USER&pwd=$PASS&returnUrl=" --compressed -i > $HTTP_FILE 
doLog "Login_Handler.ashx response"

curl -b "ItDoor=xiaolin;" -b $COOKIE_FILE 'http://www.zhongchoucar.com/Info/T493000657/Front/AjaxValedate/StorCity.ashx' -H 'Pragma: no-cache' -H 'Origin: http://www.zhongchoucar.com' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Accept: */*' -H 'Cache-Control: no-cache' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' -H 'Referer: http://www.zhongchoucar.com/Index.aspx' --data 'country=%E4%B8%AD%E5%9B%BD&province=%E5%8C%97%E4%BA%AC&city=%E5%8C%97%E4%BA%AC' --compressed -i >> $HTTP_FILE 
doLog "Exit"
