#!/bin/bash

cd $(dirname $0)
source common.sh
doLog "Start"

source user_map.sh

for USER in ${USER_MAP[*]};do
	NAME=$(echo $USER|awk -F"|" '{print $1}')
	PASS=$(echo $USER|awk -F"|" '{print $2}')
	./user_login.sh $NAME $PASS
	FILE_NAME=$(ls cookies/|egrep "^$NAME"|tail -n 1)
	COOKIE_FILE="cookies/$FILE_NAME"
	doLog "V_User_Zhong.ashx request, user=$NAME get crowdfunding list"
	curl -b "ItDoor=xiaolin;" -b $COOKIE_FILE 'http://www.zhongchoucar.com/Info/T493000657/Front/UserPage/Ajax/UserZhong/V_User_Zhong.ashx' -H 'Origin: http://www.zhongchoucar.com' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: zh-CN,zh;q=0.8,en;q=0.6' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Accept: */*' -H 'Referer: http://www.zhongchoucar.com/Info/T493000657/Front/UserPage/UserZhongChou.aspx' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --data 'action=1&pageSize=50&pageNum=1&dateStart=&dateEnd=&detailDate=threeMonth&stTitle=&sysVote=1&backMoney=0' --compressed | sed -r 's/\$[0-9]+$//g' > http/list_cf_$NAME
	doLog "V_User_Zhong.ashx response, user=$NAME list create"
done
doLog "Exit"
