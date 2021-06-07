#!/bin/bash
# Author       : Lucas.zhong
# Emainl       : lucas3306@163.com
# Create time  : 2021-06-07
# Description  : CentOS7安装redis5.0.2

#failed msg
function msg() {
    echo "$1" && exit 1
}

#check centos7.
[ $(cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/') -ne 7 ] && msg "Please run this script in CentOS7 !"

#use root to run this script.
[ $(id -u) -gt 0 ] && msg "You must be root to run this script !"


function init_conf() {
    CONFDIR=/usr/local/redis/redis.conf
    cp ./redis.conf /usr/local/redis
    cp ./sentinel.conf /usr/local/redis
    sed -i "s/bind 127.0.0.1/bind 0.0.0.0/" $CONFDIR
    sed -i "s/daemonize no/daemonize yes/" $CONFDIR
    sed -i "s#pidfile /var/run/redis_6379.pid#pidfile /usr/local/redis/redis.pid#" $CONFDIR
    sed -i "s#logfile ""#logfile /usr/local/redis/redis.log#" $CONFDIR
    sed -i "s#dir ./#dir /usr/local/redis/#" $CONFDIR
    sed -i "s#appendfilename "appendonly.aof"#appendfilename "/usr/local/redis/appendonly.aof"#" $CONFDIR
}

function start_redis() {
    echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf
    sysctl -p > /dev/null
    echo "export PATH=${PATH}:/usr/local/redis/bin" >>/etc/profile
    source /etc/profile
    cp ../redis.service /usr/lib/systemd/system/redis.service && chmod +x /usr/lib/systemd/system/redis.service
    systemctl daemon-reload
    systemctl start redis && systemctl enable redis
}

#install redis5.0
function install_redis() {
    echo "Check Redis ..."
    redis-cli -v
    if [ $? -eq 0 ];then
        msg "Redis is installed! :("
    else
        tar -zxvf redis-5.0.2.tar.gz
        cd ./redis-5.0.2
        make && make install PREFIX=/usr/local/redis
        init_conf
        start_redis
        /usr/local/redis/bin/redis-cli -v
        echo "Install Redis Successful! :)"
    fi
}


function main() {
    install_redis
}

main
