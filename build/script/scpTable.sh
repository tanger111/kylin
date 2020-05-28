#!/bin/bash

#str=`echo list | hbase shell | sed -n '$p'`
#str=${str//,/ }
#arr=($str)
#length=${#arr[@]}
#
#
#snapshot() {
#  echo "table name is "$1
#  echo "snapshot '$1', 'snap_$1'" | hbase shell
#}
#
#distcp_snap() {
#  echo "snap is snap_$1"
#  hbase org.apache.hadoop.hbase.snapshot.ExportSnapshot \
#  -snapshot snap_$1 \
#  -copy-from hdfs://10.9.69.53:8020/hbase \
#  -copy-to hdfs://10.9.151.154:8020/hbase \
#  -mappers 10 -bandwidth 10000
#}
#
#for each in ${arr[*]}
#do
#    table=`echo $each | sed 's/]//g' | sed 's/\[//g' | sed 's/\"//g'`
#    if [[ $table == *KYLIN_* ]];
#    then
#      snapshot $table
#      distcp_snap $table
#    fi
#let current=current+1
#done

str=`echo list_snapshots | hbase shell | sed -n '$p'`
str=${str//,/ }
arr=($str)
length=${#arr[@]}

for each in ${arr[*]}
do
    snapshot=`echo $each | sed 's/]//g' | sed 's/\[//g' | sed 's/\"//g'`
    if [[ $snapshot == *KYLIN_* ]];
    then
      echo "$snapshot"
      echo "delete_snapshot '$snapshot'" | hbase shell
    fi
let current=current+1
done