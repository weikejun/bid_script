#!/bin/bash

cd $(dirname $0)
source common.sh
doLog "Start"

./user_login.sh $(awk -F"|" '{print $1,$2}' user.list)
./get_amount.sh $(awk -F"|" '{print $1}' user.list)
