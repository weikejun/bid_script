#!/bin/bash

cd $(dirname $0)
source common.sh
doLog "Start"

if [ -f http/withdraw_list ];then
	for USER in $(cat http/withdraw_list|sed -r "s/\s+//g");do
		NAME=$(echo $USER|awk -F"|" '{print $1}')
		PASS=$(echo $USER|awk -F"|" '{print $2}')
		PAYPASS=$(echo $USER|awk -F"|" '{print $3}')
		AMOUNT=$(echo $USER|awk -F"|" '{print $4}')
		./user_login.sh $NAME $PASS
		FILE_NAME=$(ls cookies/|egrep "^$NAME"|tail -n 1)
		COOKIE_FILE="cookies/$FILE_NAME"
		doLog "UserGetMoney.aspx request, user=$NAME withdraw"
		curl -b "ItDoor=xiaolin;" -b $COOKIE_FILE 'http://www.zhongchoucar.com/Info/T493000657/Front/UserPage/UserGetMoney.aspx' -H 'Origin: http://www.zhongchoucar.com' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: zh-CN,zh;q=0.8,en;q=0.6' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Accept: */*' -H 'Referer: http://www.zhongchoucar.com/Info/T493000657/Front/UserPage/UserZhongChou.aspx' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --compressed > http/withdraw_$NAME
		doLog "UserGetMoney.aspx response, user=$NAME withdraw"
		if [ "$AMOUNT" == "" ];then
			AMOUNT=$(grep "MoneyYong" http/withdraw_$NAME|sed -r "s/\s+//g"|grep -Po "(?<=>)[0-9\.]+")
		fi
		BANK=$(egrep "option value=\"[0-9]+\"" http/withdraw_$NAME|sed -r "s/\s+//g"|grep -Po "(?<=value=\")[0-9]+")
		if [ $(echo "$AMOUNT > 0"|bc) -ge 1 ];then
			doLog "MoneyOption.ashx request, user=$NAME, amount=$AMOUNT, bank=$BANK"
			RET=$(curl -b "ItDoor=xiaolin;" -b $COOKIE_FILE 'http://www.zhongchoucar.com/Info/T493000657/Front/UserPage/Ajax/UserGetMoney/MoneyOption.ashx' -H 'Origin: http://www.zhongchoucar.com' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: zh-CN,zh;q=0.8,en;q=0.6' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Accept: */*' -H 'Referer: http://www.zhongchoucar.com/Info/T493000657/Front/UserPage/UserGetMoney.aspx' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --data "getMoney=$AMOUNT&payPwd=$PAYPASS&forbank=$BANK" --compressed)
			doLog "MoneyOption.ashx response, user=$NAME, amount=$AMOUNT, ret=$RET" >> log/withdraw

		fi
	done
	echo -n > http/withdraw_list
fi
doLog "Exit"
