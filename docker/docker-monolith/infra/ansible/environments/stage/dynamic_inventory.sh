#!/bin/bash

app_ip=`cd ../terraform/stage && terraform output | sed 's/\"//g' | sed 's/\,//g' | awk 'FNR == 2 {print}'`

if [ "$1" == "--list" ] ; then
cat<<EOF
{
    "app": {
        "hosts": [$app_ip]
    }
}
EOF
else
  echo "{ }"
fi
