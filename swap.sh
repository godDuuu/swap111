#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# fonts color
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"
# fonts color

#root权限
root_need(){
    if [[ $EUID -ne 0 ]]; then
        echo -e "${Red}Error:This script must be run as root!${Font}"
        exit 1
    fi
}

#检测ovz
ovz_no(){
    if [[ -d "/proc/vz" ]]; then
        echo -e "${Red}Your VPS is based on OpenVZ，not supported!${Font}"
        exit 1
    fi
}

# 安装wget
install_wget(){
    echo -e "${Green}正在安装 wget...${Font}"
    yum -y install wget
}

#固定Swap数值
swapsize=2048

add_swap(){
    grep -q "swap" /etc/fstab
    if [ $? -ne 0 ]; then
        echo -e "${Green}swapfile 未发现，正在为其创建 swapfile${Font}"
        dd if=/dev/zero of=/swapfile bs=1M count=${swapsize}
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        echo '/swapfile none swap defaults 0 0' >> /etc/fstab
        echo -e "${Green}swap 创建成功，并查看信息：${Font}"
        cat /proc/swaps
        cat /proc/meminfo | grep Swap
    else
        echo -e "${Red}swapfile 已存在，swap 设置失败，请先运行脚本删除 swap 后重新设置！${Font}"
    fi
}

# 固定操作选项为添加Swap
num=1

main(){
    root_need
    ovz_no
    install_wget
    case "$num" in
        1)
        add_swap
        ;;
        2)
        del_swap
        ;;
        *)
        clear
        echo -e "${Green}请输入正确数字 [1-2]${Font}"
        sleep 2s
        main
        ;;
    esac
}

main
