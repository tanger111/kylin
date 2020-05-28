#!/bin/bash
source /etc/profile
date="`date -d today +%Y-%m-%d`"
log_file=/data/tangtao/logs/bdp_maintain_$date.log

#do kylin clean
kylin_clean() {
    kylin.sh org.apache.kylin.tool.StorageCleanupJob --delete false >> $log_file 2>&1

    kylin.sh org.apache.kylin.tool.StorageCleanupJob --delete true >> $log_file 2>&1

    echo "kylin clean complete!!!"
}

hbase_major() {
    time_start=`date "+%Y-%m-%d %H:%M:%S"`
    echo "开始进行HBase的大合并.时间:${time_start}" >> $log_file 2>&1

    str=`echo list | hbase shell | sed -n '$p'`
    #str="a,b,c"
    str=${str//,/ }
    arr=($str)
    length=${#arr[@]}
    current=1
    echo "HBase中总共有${length}张表需要合并." >> $log_file 2>&1
    echo "balance_switch false" | hbase shell | > /dev/null
    echo "HBase的负载均衡已经关闭" >> $log_file 2>&1

    for each in ${arr[*]}
    do
        table=`echo $each | sed 's/]//g' | sed 's/\[//g'`
        echo "开始合并第${current}/${length}张表,表的名称为:${table}" >> $log_file 2>&1
        echo "major_compact ${table}" | hbase shell | > /dev/null
        let current=current+1
    done

    echo "balance_switch true" | hbase shell | > /dev/null
    echo "HBase的负载均衡已经打开." >> $log_file 2>&1

    time_end=`date "+%Y-%m-%d %H:%M:%S"`
    echo "HBase的大合并完成.时间:${time_end}" >> $log_file 2>&1
    duration=$($(date +%s -d "$finish_time")-$(date +%s -d "$start_time"))
    echo "耗时:${duration}s" >> $log_file 2>&1
}

kylin_clean

weekday=`date +%w`
if [ $weekday -eq 1 ];
then
    hbase_major
fi

