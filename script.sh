#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
File_Dir=$(pwd)

set_text_color(){
    COLOR_RED='\E[1;31m'
    COLOR_GREEN='\E[1;32m'
    COLOR_YELOW='\E[1;33m'
    COLOR_BLUE='\E[1;34m'
    COLOR_PINK='\E[1;35m'
    COLOR_PINKBACK_WHITEFONT='\033[45;37m'
    COLOR_GREEN_LIGHTNING='\033[32m \033[05m'
    COLOR_END='\E[0m'
}

Dispaly_Selection(){
    def_Install_Select="6"
    echo -e "${COLOR_YELOW}You have 7 options for your kcptun/ss/ssr install.${COLOR_END}"
    echo "1: Install Shadowsocks-libev"
    echo "2: Install ShadowsocksR(python)"
    echo "3: Install KCPTUN"
    echo "4: Install Shadowsocks-libev + KCPTUN"
    echo "5: Install ShadowsocksR(python) + KCPTUN"
    echo "6: Install ShadowsocksRR(python)"
    echo "7: Install ShadowsocksRR(python) + KCPTUN [default]"
    read -p "Enter your choice (1, 2, 3, 4, 5, 6, 7 or exit. default [${def_Install_Select}]): " Install_Select

    case "${Install_Select}" in
    1)
        echo
        echo -e "${COLOR_PINK}You will install Shadowsocks-libev ${SS_LIBEV_VER}${COLOR_END}"
        ;;
    2)
        echo
        echo -e "${COLOR_PINK}You will install ShadowsocksR(python) ${SSR_VER}${COLOR_END}"
        ;;
    3)
        echo
        echo -e "${COLOR_PINK}You will install KCPTUN ${KCPTUN_VER}${COLOR_END}"
        ;;
    4)
        echo
        echo -e "${COLOR_PINK}You will install Shadowsocks-libev ${SS_LIBEV_VER} + KCPTUN ${KCPTUN_VER}${COLOR_END}"
        ;;
    5)
        echo
        echo -e "${COLOR_PINK}You will install ShadowsocksR(python) ${SSR_VER} + KCPTUN ${KCPTUN_VER}${COLOR_END}"
        ;;
    6)
        echo
        echo -e "${COLOR_PINK}You will install ShadowsocksRR(python) ${SSRR_VER}${COLOR_END}"
        ;;
    7)
        echo
        echo -e "${COLOR_PINK}You will install ShadowsocksRR(python) ${SSRR_VER} + KCPTUN ${KCPTUN_VER}${COLOR_END}"
        ;;
    [eE][xX][iI][tT])
        echo -e "${COLOR_PINK}You select <Exit>, shell exit now!${COLOR_END}"
        exit 1
        ;;
    *)
        echo
        echo -e "${COLOR_PINK}No input,You will install ShadowsocksRR(python) ${COLOR_END}"
        Install_Select="${def_Install_Select}"
    esac
    export Install_Select
    export def_Install_Select
}

check_ss_ssr_kcp_installed(){
    ss_libev_installed_flag=""
    ssr_installed_flag=""
    ssrr_installed_flag=""
    kcptun_installed_flag=""
    kcptun_install_flag=""
    ss_libev_install_flag=""
    ssr_install_flag=""
    ssrr_install_flag=""
    if [ "${Install_Select}" == "1" ] || [ "${Install_Select}" == "4" ] || [ "${Update_Select}" == "1" ] || [ "${Update_Select}" == "5" ] || [ "${Uninstall_Select}" == "1" ] || [ "${Uninstall_Select}" == "5" ]; then
            ss_libev_installed_flag="true"
        else
            ss_libev_installed_flag="false"
    fi
    if [ "${Install_Select}" == "2" ] || [ "${Install_Select}" == "5" ] || [ "${Update_Select}" == "2" ] || [ "${Update_Select}" == "5" ] || [ "${Uninstall_Select}" == "2" ] || [ "${Uninstall_Select}" == "5" ]; then
            ssr_installed_flag="true"
        else
            ssr_installed_flag="false"
    fi
    if [ "${Install_Select}" == "6" ] || [ "${Install_Select}" == "7" ] || [ "${Update_Select}" == "4" ] || [ "${Update_Select}" == "5" ] || [ "${Uninstall_Select}" == "4" ] || [ "${Uninstall_Select}" == "5" ]; then
            ssrr_installed_flag="true"
        else
            ssrr_installed_flag="false"
    fi
    if [ "${Install_Select}" == "3" ] || [ "${Install_Select}" == "4" ] || [ "${Install_Select}" == "5" ] || [ "${Install_Select}" == "7" ] || [ "${Update_Select}" == "3" ] || [ "${Update_Select}" == "5" ] || [ "${Uninstall_Select}" == "3" ] || [ "${Uninstall_Select}" == "5" ]; then
            kcptun_installed_flag="true"
        else
            kcptun_installed_flag="false"
    fi
}

BBR_Selection(){
    def_bbr_select="2"
    echo -e "${COLOR_YELOW}You have 2 options for bbr install.${COLOR_END}"
    echo "1: Install BBR with Rinetd"
    echo "2: Install BBR with LML"
    read -p "Enter your choice (1, 2 or exit. default [${def_bbr_select}]): " bbr_select
    case "${bbr_select}" in
    1)
        echo
        echo -e "${COLOR_PINK}You will install BBR with Rinetd ${SS_LIBEV_VER}${COLOR_END}"
        ;;
    2)
        echo
        echo -e "${COLOR_PINK}You will install Install BBR with LKL ${SSR_VER}${COLOR_END}"
        ;;
    [eE][xX][iI][tT])
        echo -e "${COLOR_PINK}You select <Exit>, shell exit now!${COLOR_END}"
        exit 1
        ;;
    *)
        echo
        echo -e "${COLOR_PINK}No input,You will install install BBR with LML ${COLOR_END}"
        bbr_select="${def_bbr_select}"
    esac
}

set_tool(){
    echo -e "${COLOR_YELOW}set tool...${COLOR_END}"
    wget --no-check-certificate https://raw.githubusercontent.com/Jenking-Zhang/shell/master/ss_ssr_kcp_bbr_netspeeder/tool.sh
    chmod +x /root/tool.sh
}

set_timezone(){
    echo -e "${COLOR_YELOW}set time zone...${COLOR_END}"
    rm -rf /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    echo "done."
}

update_system(){
    echo -e "${COLOR_YELOW}update system...${COLOR_END}"
    yum update -y
}

install_base_software(){
    echo -e "${COLOR_YELOW}install base package...${COLOR_END}"
    yum install epel-release -y
    yum install -y gcc-c++ wget kernel-headers make unzip cronie git lrzsz pcre-devel
    chkconfig crond on
    service crond start
}

update_glibc(){
    echo -e "${COLOR_YELOW}update glibc...${COLOR_END}"
    wget -c http://ftp.redsleeve.org/pub/steam/glibc-2.15-60.el6.x86_64.rpm \
    http://ftp.redsleeve.org/pub/steam/glibc-common-2.15-60.el6.x86_64.rpm \
    http://ftp.redsleeve.org/pub/steam/glibc-devel-2.15-60.el6.x86_64.rpm \
    http://ftp.redsleeve.org/pub/steam/glibc-headers-2.15-60.el6.x86_64.rpm \
    http://ftp.redsleeve.org/pub/steam/nscd-2.15-60.el6.x86_64.rpm
    rpm -Uvh glibc-2.15-60.el6.x86_64.rpm \
    glibc-common-2.15-60.el6.x86_64.rpm \
    glibc-devel-2.15-60.el6.x86_64.rpm \
    glibc-headers-2.15-60.el6.x86_64.rpm \
    nscd-2.15-60.el6.x86_64.rpm
}

install_ss_ssr_ssrr_kcp(){
    echo -e "${COLOR_YELOW}install ss_ssr_ssrr_kcp...${COLOR_END}"
    wget --no-check-certificate https://raw.githubusercontent.com/Jenking-Zhang/shell/master/ss_ssr_kcp_bbr_netspeeder/ss_ssr_ssrr_kcp.sh
    chmod +x ./ss_ssr_ssrr_kcp.sh
    ./ss_ssr_ssrr_kcp.sh install
}

reconfig_software(){
    echo -e "${COLOR_YELOW}reconfig ss_ssr_ssrr_kcp...${COLOR_END}"
    if [ "${ss_libev_installed_flag}" == "true" ] ;then
        mv -f shadowsocks-libev.json /etc/shadowsocks-libev/config.json
        /etc/init.d/shadowsocks restart
    else 
        rm -f shadowsocks-libev.json
    fi
    if [ "${ssr_installed_flag}" == "true" ] ;then
        mv -f shadowsocksR.json /usr/local/shadowsocksR/
        /etc/init.d/ssr restart
        else 
        rm -f shadowsocksR.json shadowsocksR-Origin.json
    fi
    if [ "${ssrr_installed_flag}" == "true" ] ;then
        mv -f shadowsocksRR.json /usr/local/shadowsocksRR/user-config.json
        /etc/init.d/ssrr restart
    else 
        rm -f shadowsocksRR.json shadowsocksRR-Origin.json
    fi
    if [ "${kcptun_installed_flag}" == "true" ] ;then
        mv -f kcptun.json /usr/local/kcptun/config.json
        /etc/init.d/kcptun restart
    else 
        rm -f kcptun.json
    fi
}

install_bbr(){
    if [ "${bbr_select}" == "1" ] ;then
        echo -e "${COLOR_PINK}install BBR with Rinetd...${COLOR_END}"
        wget --no-check-certificate https://raw.githubusercontent.com/Jenking-Zhang/shell/master/ss_ssr_kcp_bbr_netspeeder/get-rinetd-bbr.sh
        chmod +x get-rinetd-bbr.sh
        ./get-rinetd-bbr.sh
    else
        update_glibc      
        echo -e "${COLOR_PINK}install BBR with LKL...${COLOR_END}"
        wget --no-check-certificate https://raw.githubusercontent.com/Jenking-Zhang/shell/master/ss_ssr_kcp_bbr_netspeeder/ovz-bbr-installer.sh
        chmod +x ovz-bbr-installer.sh
        ./ovz-bbr-installer.sh
    fi
}

install_axel(){
    echo -e "${COLOR_YELOW}install axel...${COLOR_END}"
    cd /root
    wget -c http://ftp.tu-chemnitz.de/pub/linux/dag/redhat/el6/en/x86_64/rpmforge/RPMS/axel-2.4-1.el6.rf.x86_64.rpm
    rpm -ivh axel-2.4-1.el6.rf.x86_64.rpm
}

set_crontab(){
    echo -e "${COLOR_YELOW}set crontab...${COLOR_END}"
    echo "27 3 * * 2,5 /sbin/reboot" >> /var/spool/cron/root
    if [ "${ss_libev_installed_flag}" == "true" ] ;then echo "28 3 * * * /etc/init.d/ssr restart" >> /var/spool/cron/root; fi
    if [ "${ssr_installed_flag}" == "true" ] ;then echo "28 3 * * * /etc/init.d/ssr restart" >> /var/spool/cron/root; fi
    if [ "${ssrr_installed_flag}" == "true" ] ;then echo "28 3 * * * /etc/init.d/ssrr restart" >> /var/spool/cron/root; fi
    if [ "${kcptun_installed_flag}" == "true" ] ;then echo "29 3 * * * /etc/init.d/kcptun restart" >> /var/spool/cron/root; fi
    if [ "${bbr_select}" == "1" ] ;then
       echo "29 3 * * * /etc/init.d/bbr restart" >> /var/spool/cron/root
    else
       echo "29 3 * * * service haproxy-lkl restart" >> /var/spool/cron/root
    fi
    service crond restart
}

clean_files(){
    echo -e "${COLOR_YELOW}clean files...${COLOR_END}"
    rm -f install.sh ovz-bbr-installer.sh script.sh get-rinetd-bbr.sh axel-2.4-1.el6.rf.x86_64.rpm glibc-2.15-60.el6.x86_64.rpm glibc-common-2.15-60.el6.x86_64.rpm glibc-devel-2.15-60.el6.x86_64.rpm glibc-headers-2.15-60.el6.x86_64.rpm nscd-2.15-60.el6.x86_64.rpm
    echo "done."
}

    set_text_color
    Dispaly_Selection
    check_ss_ssr_kcp_installed
    BBR_Selection
    set_timezone
    update_system
    install_base_software
    install_ss_ssr_ssrr_kcp
    reconfig_software
    set_tool
    install_bbr
    install_axel
    set_crontab
    clean_files
    reboot
exit 0
