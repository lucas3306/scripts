#!/bin/bash
# Author       : Lucas.zhong
# Emainl       : lucas3306@163.com
# Create time  : 2021-06-03
# Description  : CentOS7安装docker，docker-compose

#failed msg
function msg() {
    echo "$1" && exit 1
}

#check centos7.
[ $(cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/') -ne 7 ] && msg "Please run this script in CentOS7 !"

#use root to run this script.
[ $(id -u) -gt 0 ] && msg "You must be root to run this script !"

#install docker19.03
function install_docker() {
    echo "Check Docker ..."
    docker -v
    if [ $? -eq 0 ];then
        msg "Docker is installed! :("
    else
        tar -zxvf docker-19.03.15.tgz
        cp ./docker/* /usr/bin/
        cp ./docker.service /etc/systemd/system/docker.service && chmod +x /etc/systemd/system/docker.service
        systemctl daemon-reload 
        systemctl start docker && systemctl enable docker
        docker -v
        echo "Install Docker Successful! :)"
    fi
}

#install docker-compose-1.26.0
function install_docker_compose() {
    echo "Check Docker-compose ..."
    docker-compose -v
    if [ $? -eq 0 ];then
        msg "Docker-compose is installed! :("
    else
        cp ./docker-compose /usr/local/bin/ && chmod +x /usr/local/bin/docker-compose
        ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
        docker-compose -v
        echo "Install Docker-compose Successful! :)"
    fi 
}

function main() {
    install_docker
    install_docker_compose
}

main
