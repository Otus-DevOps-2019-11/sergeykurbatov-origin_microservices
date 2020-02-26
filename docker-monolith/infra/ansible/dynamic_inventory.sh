#!/bin/bash

app_ip=`cd ../terraform/stage && terraform output | grep app_external_ip | awk '{print $3}'`

if [ "$1" == "--list" ] ; then
cat<<EOF
{
    "app": {
        "hosts": [$app_ip],
    }
}
EOF
else
  echo "{ }"
fi
