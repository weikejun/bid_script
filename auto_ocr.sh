#!/bin/bash

cd $(dirname $0)
source common.sh
doLog "Start"

exit

while [ 1 -eq 1 ];do
	if [ "$(ls captcha/|grep .gif)" != "" ];then
		for f in $(ls captcha/*.gif|xargs);do
			FNAME=$(basename $f .gif)
			if [ -f captcha/$FNAME.res ];then
				continue
			fi
			if [ "$(file --mime-type $f |awk '{print $2}')" != "image/gif" ];then
				doLog "Error gif, $f"
				continue
			fi
			convert $f -fuzz 40% -transparent white -alpha extract -negate -resize 180x75 /tmp/$FNAME.jpg > /dev/null
			tesseract /tmp/$FNAME.jpg /tmp/$FNAME -l eng -psm 6 > /dev/null
			CAPTCHA=$(eval "echo|awk '{printf \"%d\n\", $(cat /tmp/$FNAME.txt|sed -r 's/[f]/1/g'|sed -r 's/[^0-9\+\-]//g')}'") 
			echo -n $CAPTCHA > captcha/$FNAME.res
			touch $f
			doLog "OCR $f ok, res=$CAPTCHA"
		done
	fi
	sleep 0.5
done

doLog "Exit"
