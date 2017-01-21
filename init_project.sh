#!/bin/bash

cd $(dirname $0)
source common.sh

mkdir -p log tigger amount http cookies captcha/archives 
touch user.list
chmod 777 log tigger amount http cookies captcha/archives captcha user.list
echo "qwerty163|wkj12345678" > user.list
echo "2878|/Info/T493000657/Front/InsideTwo/InsideTwo.aspx?Id=0CFA5440348BDE13" > car.list.debug

