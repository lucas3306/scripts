#!/bin/bash
# Author       : Lucas.zhong
# Emainl       : lucas3306@163.com
# Create time  : 2021-06-07
# Description  : CentOS7安装nginx1.20.1

#failed msg
function msg() {
    echo "$1" && exit 1
}

#check centos7.
[ $(cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/') -ne 7 ] && msg "Please run this script in CentOS7 !"

#use root to run this script.
[ $(id -u) -gt 0 ] && msg "You must be root to run this script !"

#init env
function init_env() {
    useradd nginx -s /sbin/nologin -M
    yum repolist > /dev/null
    if [ $? -eq 0 ];then
        yum -y install gcc c++ pcre  pcre-devel openssl openssl-devel  make zlib zlib-devel
    else
        msg "Please check yum repo! :("
    fi
}

#install nginx1.20.1
function install_nginx() {
    cfg="--prefix=/usr/local/nginx --conf-path=/usr/local/nginx/conf/nginx.conf \
         --user=nginx --group=nginx \
         --with-http_ssl_module --with-http_stub_status_module \
         --with-http_gzip_static_module  --with-http_gunzip_module \
         --with-http_v2_module --with-http_realip_module"

    echo "Check Nginx ..."
    nginx -v 
    if [ $? -eq 0 ];then
        msg "Nginx is installed! :("
    else
        init_env
        tar -zxvf nginx-1.20.1.tar.gz
        cd ./nginx-1.20.1
        ./configure $cfg
        make && make install 
        cp ../nginx.service /usr/lib/systemd/system/nginx.service && chmod +x /usr/lib/systemd/system/nginx.service
        systemctl daemon-reload
        systemctl start nginx && systemctl enable nginx
        ln -s /usr/local/nginx/sbin/nginx /usr/local/bin
        nginx -v
        echo "Install Nginx Successful! :)"
    fi
}

function main() {
   install_nginx
}

main
