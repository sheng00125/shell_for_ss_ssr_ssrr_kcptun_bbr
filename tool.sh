#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

cur_dir=$(pwd)
ssr_origin_config=/root/shadowsocksR-Origin.json
ssrr_origin_config=/root/shadowsocksRR-Origin.json
bbr_version=`cat /etc/rinetd-bbr/bbr.conf |sed -n '/'^#bbr_version='/p' | cut -d\" -f2`
remote_bbr_version=$(wget --no-check-certificate -qO- https://api.github.com/repos/linhua55/lkl_study/releases/latest | grep 'tag_name' | cut -d\" -f4)
RINET_BBR_URL="https://github.com/linhua55/lkl_study/releases/download/${remote_bbr_version}/rinetd_bbr_powered"

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
shell_update(){
    echo "+ Check updates for shell..."
    echo
    version=`cat ss_ssr_ssrr_kcp_bbr.sh |sed -n '/'^version'/p' | cut -d\" -f2`
    shell_download_link=`cat ss_ssr_ssrr_kcp_bbr.sh |sed -n '/'^shell_download_link'/p' | cut -d\" -f2`
    remote_shell_version=`wget --no-check-certificate -qO- ${shell_download_link} | sed -n '/'^version'/p' | cut -d\" -f2`
    echo -e "Shell remote version :${COLOR_GREEN}${remote_shell_version}${COLOR_END}"
    echo -e "Shell local version :${COLOR_GREEN}${version}${COLOR_END}"
    if [ ! -z ${remote_shell_version} ]; then
        if [[ "${version}" != "${remote_shell_version}" ]];then
            echo -e "${COLOR_GREEN}Found a new version of shell,please update shell!${COLOR_END}"
        else
            echo "Local shell is up-to-date!"
        fi
    fi
    echo
}
Dispaly_Selection(){
    def_Select=1
    echo -e "${COLOR_YELOW}You have 3 options for your ss/ssr/ssrr/kcptun operation.${COLOR_END}"
    echo "1: Update All Programe（SS-libev,SSR,SSRR,KCPTUN,BBR）"
    echo "2: Switch ShadowsocksR(python) Config"
    echo "3: Switch ShadowsocksRR(python) Config"
    read -p "Enter your choice (1, 2,3 or exit. default [${def_Select}]): " Select
    case "${Select}" in
    1)
        echo
        echo -e "${COLOR_PINK}You will update programe!${COLOR_END}"
        echo   
        ;;
    2)
        echo
            echo -e "${COLOR_PINK}You will switch ShadowsocksR(python) config!${COLOR_END}"
        echo   
        ;;
    3)
        echo
        echo -e "${COLOR_PINK}You will switch ShadowsocksRR(python) config!${COLOR_END}"
                echo
        ;;
    [eE][xX][iI][tT])
        echo -e "${COLOR_PINK}You select <Exit>, shell exit now!${COLOR_END}"
        exit 1
        ;;
    *)
        echo
        echo -e "${COLOR_PINK}No input,You will update programe.${COLOR_END}"
        Select="${def_Select}"
    esac
}
Press_Start(){
    echo ""
    echo -e "${COLOR_GREEN}Press any key to continue...or Press Ctrl+C to cancel${COLOR_END}"
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
}
check_ssr_ssrr_installed(){
    ssr_installed_flag=""
    ssrr_installed_flag=""
    if [ "${Select}" == "2" ]; then
        if [[ ! -x /usr/local/shadowsocksR/shadowsocks/server.py ]] || [[ ! -s /usr/local/shadowsocksR/shadowsocks/__init__.py ]]; then
            echo -e "${COLOR_RED}Error,ShadowsocksR not installed${COLOR_END}"
            exit 1
        fi
    fi
    if [ "${Select}" == "3" ]; then
        if [[ ! -x /usr/local/shadowsocksRR/shadowsocks/server.py ]] || [[ ! -s /usr/local/shadowsocksRR/shadowsocks/__init__.py ]]; then
            echo -e "${COLOR_RED}Error,ShadowsocksRR not installed${COLOR_END}"
                       exit 1
        fi
    fi
}
check_bbr_update(){
echo -e "BBR remote version :${COLOR_GREEN}${remote_bbr_version}${COLOR_END}"
echo -e "BBR local version :${COLOR_GREEN}${bbr_version}${COLOR_END}"
    if [ ! -z ${remote_bbr_version} ]; then
        if [[ "${bbr_version}" != "${remote_bbr_version}" ]];then
            echo -e "${COLOR_GREEN}Found a new version of BBR,update now...${COLOR_END}"
            Press_Start
            update_bbr
        else
            echo "BBR local version is up-to-date."
        fi
    else
        echo -e "${COLOR_RED}Error: ${COLOR_END}Get BBR version failed!"
        exit 1
    fi
}
update_bbr(){
/etc/init.d/bbr stop
if [ -f /etc/rinetd-bbr/bbr.conf ]; then rm -rf /etc/rinetd-bbr/bbr.conf;fi
if [ -f /usr/bin/rinetd-bbr ]; then rm -rf /usr/bin/rinetd-bbr;fi
curl -L "${RINET_BBR_URL}" >/usr/bin/rinetd-bbr
chmod +x /usr/bin/rinetd-bbr
cat <<EOF > /etc/rinetd-bbr/bbr.conf
#bbr_version="${remote_bbr_version}"
# bindadress bindport connectaddress connectport
0.0.0.0 443 0.0.0.0 443
EOF
    /etc/init.d/bbr start
}
update_programe(){
 ./ss_ssr_ssrr_kcp_bbr.sh update
check_bbr_update
}
switch_ssr_config(){
if [ -f "$ssr_origin_config" ]; then
    echo -e "${COLOR_PINK}You will switch config to ${COLOR_END}${COLOR_GREEN}shadowsocksR-Origin.json${COLOR_END}"
    echo
    mv -f /usr/local/shadowsocksR/shadowsocksR.json shadowsocksR.json > /dev/null
    mv -f shadowsocksR-Origin.json /usr/local/shadowsocksR/shadowsocksR.json > /dev/null
    /etc/init.d/ssr restart
    echo -e "${COLOR_GREEN}currently config:${COLOR_END}"
    /etc/init.d/ssr viewconfig
    echo
else
    echo -e "${COLOR_PINK}You will switch config to ${COLOR_END}${COLOR_GREEN}shadowsocksR.json${COLOR_END}"
    echo
    mv -f /usr/local/shadowsocksR/shadowsocksR.json shadowsocksR-Origin.json > /dev/null
    mv -f shadowsocksR.json /usr/local/shadowsocksR/shadowsocksR.json > /dev/null
    /etc/init.d/ssr restart
    echo -e "${COLOR_GREEN}currently config:${COLOR_END}"
    /etc/init.d/ssr viewconfig
    echo
fi
}
switch_ssrr_config(){
if [ -f "$ssrr_origin_config" ]; then
    echo -e "${COLOR_PINK}You will switch config to ${COLOR_END}${COLOR_GREEN}shadowsocksRR-Origin.json${COLOR_END}"
    echo
    mv -f /usr/local/shadowsocksRR/user-config.json shadowsocksRR.json > /dev/null
    mv -f shadowsocksRR-Origin.json /usr/local/shadowsocksRR/user-config.json > /dev/null
    /etc/init.d/ssrr restart
    echo -e "${COLOR_GREEN}currently config:${COLOR_END}"
    /etc/init.d/ssrr viewconfig
else
    echo -e "${COLOR_PINK}You will switch config to ${COLOR_END}${COLOR_GREEN}shadowsocksRR.json${COLOR_END}"
    echo
    mv -f /usr/local/shadowsocksRR/user-config.json shadowsocksRR-Origin.json > /dev/null
    mv -f shadowsocksRR.json /usr/local/shadowsocksRR/user-config.json > /dev/null
    /etc/init.d/ssrr restart
    echo -e "${COLOR_GREEN}currently config:${COLOR_END}"
    /etc/init.d/ssrr viewconfig
fi
}
action(){
 if [ "${Select}" == "1" ]; then
    update_programe
 fi
 if [ "${Select}" == "2" ]; then
    check_ssr_ssrr_installed
    switch_ssr_config
    shell_update
 fi 
 if [ "${Select}" == "3" ]; then
    check_ssr_ssrr_installed
    switch_ssrr_config
    shell_update
 fi 
}

set_text_color
clear
Dispaly_Selection
action
exit
