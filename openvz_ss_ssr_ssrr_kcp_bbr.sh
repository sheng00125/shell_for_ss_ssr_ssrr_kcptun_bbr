#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

shell_version="2.0.7"
shell_download_link="https://raw.githubusercontent.com/onekeyshell/kcptun_for_ss_ssr/master/kcptun_for_ss_ssr-install.sh"
program_version_link="https://raw.githubusercontent.com/Jenking-Zhang/shell_for_ss_ssr_ssrr_kcptun_bbr/master/version.sh"
ss_libev_config="/etc/shadowsocks-libev/config.json"
ssr_config="/usr/local/shadowsocksR/shadowsocksR.json"
ssrr_config="/usr/local/shadowsocksRR/user-config.json"
kcptun_config="/usr/local/kcptun/config.json"

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install SS/SSR/SSRR/KCPTUN/BBR"
    exit 1
fi
set_timezone(){
    echo -e "${COLOR_YELOW}+ Set timezone...${COLOR_END}"
    rm -rf /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    echo "done."
}
shell_update(){
    clear
    echo "+ Check updates for shell..."
    echo
    remote_shell_version=`wget --no-check-certificate -qO- ${shell_download_link} | sed -n '/'^version'/p' | cut -d\" -f2`
    echo -e "Shell remote version :${COLOR_GREEN}${remote_shell_version}${COLOR_END}"
    echo -e "Shell local version :${COLOR_GREEN}${shell_version}${COLOR_END}"
    if [ ! -z ${remote_shell_version} ]; then
        if [[ "${shell_version}" != "${remote_shell_version}" ]];then
            echo -e "${COLOR_GREEN}Found a new version of shell(ver:${remote_shell_version})!${COLOR_END}"
	    echo -e "${COLOR_YELOW}You have 2 options for your shell update.${COLOR_END}"
            echo "1: Continue with currently shell"
            echo "2: Exit to update shell"
            echo
	    read -p "Enter your choice (1, 2 or exit. default [${def_shell_update_Select}]): " shell_update_Select
	    case "${shell_update_Select}" in
                1)
                    echo
                    echo -e "${COLOR_PINK}You will continue with currently shell ${SS_LIBEV_VER}${COLOR_END}"
                    ;;
                2)
                    echo
                    echo -e "${COLOR_PINK}You will exit ${SSR_VER}${COLOR_END}"
                    exit 1
                    ;;
                [eE][xX][iI][tT])
                    echo -e "${COLOR_PINK}You select <Exit>, shell exit now!${COLOR_END}"
                    exit 1
                    ;;
                *)
                    echo
                    echo -e "${COLOR_PINK}No input or input error,You will continue with currently shell ${COLOR_END}"
            esac
        else
            echo -e "${COLOR_PINK}Shell is up-to-date!${COLOR_END}"
        fi
    fi
}
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
# Check OS
version_ge(){
    test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"
}
version_gt(){
    test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"
}
check_kernel_version() {
    local kernel_version=$(uname -r | cut -d- -f1)
    if version_gt ${kernel_version} 3.7.0; then
        return 0
    else
        return 1
    fi
}
Get_Dist_Name(){
    release=''
    systemPackage=''
    DISTRO=''
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        release="centos"
        systemPackage='yum'
    elif grep -Eqi "centos|red hat|redhat" /etc/issue || grep -Eqi "centos|red hat|redhat" /etc/*-release; then
        DISTRO='RHEL'
        release="centos"
        systemPackage='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
        DISTRO='Aliyun'
        release="centos"
        systemPackage='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
        release="centos"
        systemPackage='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        release="debian"
        systemPackage='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        release="ubuntu"
        systemPackage='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        release="debian"
        systemPackage='apt'
    elif grep -Eqi "Deepin" /etc/issue || grep -Eq "Deepin" /etc/*-release; then
        DISTRO='Deepin'
        release="debian"
        systemPackage='apt'
    else
        release='unknow'
    fi
    Get_OS_Bit
}
# Check OS bit
Get_OS_Bit(){
    ARCHS=""
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        Is_64bit='y'
        ARCHS="amd64"
    else
        Is_64bit='n'
        ARCHS="386"
    fi
}
# Check system
check_sys(){
    local checkType=$1
    local value=$2
    if [[ ${checkType} == "sysRelease" ]]; then
        if [ "$value" == "$release" ]; then
            return 0
        else
            return 1
        fi
    elif [[ ${checkType} == "packageManager" ]]; then
        if [ "$value" == "$systemPackage" ]; then
            return 0
        else
            return 1
        fi
    fi
}
# Get version
getversion(){
    if [[ -s /etc/redhat-release ]]; then
        grep -oE  "[0-9.]+" /etc/redhat-release
    else
        grep -oE  "[0-9.]+" /etc/issue
    fi
}
# CentOS version
centosversion(){
    if check_sys sysRelease centos; then
        local code=$1
        local version="$(getversion)"
        local main_ver=${version%%.*}
        if [ "$main_ver" == "$code" ]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}
get_opsy(){
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}
debianversion(){
    if check_sys sysRelease debian;then
        local version=$( get_opsy )
        local code=${1}
        local main_ver=$( echo ${version} | sed 's/[^0-9]//g')
        if [ "${main_ver}" == "${code}" ];then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}
Check_OS_support(){
    # Check OS system
    if [ "${release}" == "unknow" ]; then
        echo
        echo -e "${COLOR_RED}Error: Unable to get Linux distribution name, or do NOT support the current distribution.${COLOR_END}"
        echo
        exit 1
    elif [ "${DISTRO}" == "CentOS" ]; then
        if centosversion 5; then
            echo
            echo -e "${COLOR_RED}Not support CentOS 5, please change to CentOS 6 or 7 and try again.${COLOR_END}"
            echo
            exit 1
        fi
    fi
}
Press_Install(){
    echo ""
    echo -e "${COLOR_GREEN}Press any key to install...or Press Ctrl+C to cancel${COLOR_END}"
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
}
Press_Start(){
    echo ""
    echo -e "${COLOR_GREEN}Press any key to continue...or Press Ctrl+C to cancel${COLOR_END}"
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
}
Press_Exit(){
    echo ""
    echo -e "${COLOR_GREEN}Press any key to Exit...or Press Ctrl+C cancel${COLOR_END}"
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
}
Print_Sys_Info(){
    cat /etc/issue
    cat /etc/*-release
    uname -a
    MemTotal=`free -m | grep Mem | awk '{print  $2}'`
    echo "Memory is: ${MemTotal} MB "
    df -h
}
Disable_Selinux(){
    if [ -s /etc/selinux/config ]; then
        sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
    fi
}
error_detect_depends(){
    local command=$1
    local depend=`echo "${command}" | awk '{print $4}'`
    ${command}
    if [ $? != 0 ]; then
        echo -e "[${red}Error${COLOR_END} Failed to install ${red}${depend}${plain}"
        exit 1
    fi
}
pre_install_packs(){
    if check_sys packageManager yum; then
        echo -e "[${COLOR_GREEN}Info${COLOR_END} Checking the EPEL repository..."
        if [ ! -f /etc/yum.repos.d/epel.repo ]; then
            yum install -y -q epel-release
        fi
        [ ! -f /etc/yum.repos.d/epel.repo ] && echo -e "[${COLOR_RED}Error:install EPEL repository failed, please check it.${COLOR_END}" && exit 1
        [ ! "$(command -v yum-config-manager)" ] && yum install -y -q yum-utils
        if [ x"`yum-config-manager epel | grep -w enabled | awk '{print $3}'`" != x"True" ]; then
            yum-config-manager --enable epel
        fi
        echo -e "[${COLOR_GREEN}Info${COLOR_END}] Checking the EPEL repository complete..."
        yum_depends=(
            unzip gzip openssl openssl-devel gcc python python-devel python-setuptools pcre pcre-devel libtool libevent xmlto
            autoconf automake make curl curl-devel zlib-devel perl perl-devel cpio expat-devel gettext-devel asciidoc
            libev-devel c-ares-devel git udns-devel qrencode kernel-headers lrzsz
        )
        for depend in ${yum_depends[@]}; do
            error_detect_depends "yum -y install ${depend}"
        done
        if centosversion 6; then
            update_glibc
	    update_autoconf
	    yum update nss -y
	    yum update -y
	fi
    elif check_sys packageManager apt; then
        apt_depends=(
            gettext build-essential unzip gzip python python-dev python-setuptools curl openssl libssl-dev
            autoconf automake libtool gcc make perl cpio libpcre3 libpcre3-dev zlib1g-dev libev-dev libc-ares-dev git qrencode 
        )
        apt-get -y update
        for depend in ${apt_depends[@]}; do
            error_detect_depends "apt-get -y install ${depend}"
        done
	apt-get upgrade -y
    fi
}
update_glibc(){
    echo -e "+ Update glibc...."
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
update_autoconf(){
    echo -e "+ Update autoconf...."
    cd ${cur_dir}
    rpm -e --nodeps autoconf-2.63
    wget ftp://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
    tar zxvf autoconf-2.69.tar.gz
    cd autoconf-2.69
    ./configure --prefix=/usr/
    make && make install
}
# Random password
randstr(){
  index=0
  strRandomPass=""
  for i in {a..z}; do arr[index]=$i; index=`expr ${index} + 1`; done
  for i in {A..Z}; do arr[index]=$i; index=`expr ${index} + 1`; done
  for i in {0..9}; do arr[index]=$i; index=`expr ${index} + 1`; done
  for i in {1..16}; do strRandomPass="$strRandomPass${arr[$RANDOM%$index]}"; done
  echo $strRandomPass
}
get_ip(){
    local IP=$(ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1)
    [ -z ${IP} ] && IP=$(wget -qO- -t1 -T2 ip.clang.cn | sed -r 's/\r//')
    [ -z ${IP} ] && IP=$(wget -qO- -t1 -T2 ipv4.icanhazip.com | sed -r 's/\r//')
    [ ! -z ${IP} ] && echo ${IP} || echo
}
Dispaly_Selection(){
    def_Install_Select="1"
    echo -e "${COLOR_YELOW}You have 7 options for your ss/ssr/ssrr/kcptun install.${COLOR_END}"
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
            echo -e "${COLOR_PINK}You will Install Shadowsocks-libev ${SS_LIBEV_VER} + KCPTUN ${KCPTUN_VER}${COLOR_END}"
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
            echo -e "${COLOR_PINK}No input or input error,You will install Shadowsocks-libev${COLOR_END}"
            Install_Select="${def_Install_Select}"
    esac
    if [ "${Install_Select}" == "1" ] || [ "${Install_Select}" == "4" ]; then
        def_Install_obfs="N"
        echo
        echo -e "${COLOR_YELOW}Do you want to install simple-obfs for Shadowsocks-libev?[Y/N]${COLOR_END}"
        read -p "Enter your choice fot simple-obf.default: ${def_Install_obfs}:" Install_obfs

        case "${Install_obfs}" in
            [yY])
                echo
                echo -e "${COLOR_PINK}You will install Simple-obfs for Shadowsocks-libev${COLOR_END}"
                ;;
            [nN])
                echo
                echo -e "${COLOR_PINK}You will not install Simple-obfs for Shadowsocks-libev${COLOR_END}"
                ;;
            *)
               echo -e "${COLOR_PINK}No input or input error,You will not install Simple-obfs for Shadowsocks-libev${COLOR_END}"
               Install_obfs="${def_Install_obfs}"
        esac
    fi
}
Simple_obfs_option(){
    if [ "${Install_obfs}" == "y" ] || [ "${Install_obfs}" == "Y" ]; then
        echo
      	def_ofbs_option="1"
        echo -e "${COLOR_YELOW}Please select your Simple-obfs setting:${COLOR_END}"
      	echo "1: http"
      	echo "2: tls"
      	#read -p "Enter your choice (1, 2. default ${def_ofbs_option}): " ofbs_option

	      case "${ofbs_option}" in
            1|[hH][tT][tT][pP])
	              ofbs_option="http"
                ;;
            2|[tT][lL][sS])
                ofbs_option="tls"
                ;;
            *)
                echo -e "${COLOR_PINK}No input or input error,You Simple-obfs will be set to:http${COLOR_END}"
                ofbs_option="http"
        esac
    fi
}
BBR_Selection(){
    def_bbr_select="2"
    echo
    echo -e "${COLOR_YELOW}You have 3 options for BBR install${COLOR_END}"
    echo "1: Install BBR with Rinetd"
    echo "2: Install BBR with LML"
    echo "3: Not install any BBR"
    read -p "Enter your choice (1, 2 or exit. default [${def_bbr_select}]): " bbr_select

    case "${bbr_select}" in
        1)
            echo
            echo -e "${COLOR_PINK}You will install BBR with Rinetd${COLOR_END}"
            ;;
        2)
            echo
            echo -e "${COLOR_PINK}You will install BBR with LKL${COLOR_END}"
            ;;
        3)
            echo
            echo -e "${COLOR_PINK}You will not install any BBR${COLOR_END}"
            ;;
        *)
            echo
            echo -e "${COLOR_PINK}No input or input error,You will install BBR with LML${COLOR_END}"
            bbr_select="${def_bbr_select}"
    esac
}
BBR_option(){
    if [ ${bbr_select} == "1" ] && [ ! -f rinetd_bbr.conf ];then
        while true
        do
            echo
            read -p "Please input port for BBR [1-65535]:" bbr_port
            [ -z "$set_ss_libev_port" ]
            expr ${bbr_port} + 0 &>/dev/null
            if [ $? -eq 0 ]; then
                if [ ${bbr_port} -ge 1 ] && [ ${bbr_port} -le 65535 ]; then
                    echo
                    echo "---------------------------------------"
                    echo "BBR port = ${bbr_port}"
                    echo "---------------------------------------"
                    echo
                    break
                 else
                    echo -e "${COLOR_RED}Input error, please input correct number${COLOR_END}"
                  fi
            else
                echo -e "${COLOR_RED}No input, please input correct number${COLOR_END}"
            fi
        done
    elif [ ${bbr_select} == "2" ] && [ ! -f lkl_bbr.conf ];then
        while true
        do
            echo
            read -p "Please input port for BBR [1-65535]:" bbr_port
            [ -z "$set_ss_libev_port" ]
            expr ${bbr_port} + 0 &>/dev/null
            if [ $? -eq 0 ]; then
                if [ ${bbr_port} -ge 1 ] && [ ${bbr_port} -le 65535 ]; then
                    echo
                    echo "---------------------------------------"
                    echo "BBR port = ${bbr_port}"
                    echo "---------------------------------------"
                    echo
                    break
                 else
                    echo -e "${COLOR_RED}Input error, please input correct number${COLOR_END}"
                  fi
            else
                echo -e "${COLOR_RED}No input, please input correct number${COLOR_END}"
            fi
        done
    export bbr_port
    fi
}
# Install cleanup
install_cleanup(){
    cd ${cur_dir}
    rm -rf .version.sh ${shadowsocks_libev_ver} ${shadowsocks_libev_ver}.tar.gz manyuser.zip shadowsocksr-manyuser shadowsocks-manyuser ${kcptun_latest_file} ${libsodium_laster_ver} ${libsodium_laster_ver}.tar.gz ${mbedtls_laster_ver} ${mbedtls_laster_ver}-gpl.tgz shadowsocksr-akkariiin-master ssrr.zip ovz-bbr-installer.sh glibc-2.15-60.el6.x86_64.rpm glibc-common-2.15-60.el6.x86_64.rpm glibc-devel-2.15-60.el6.x86_64.rpm glibc-headers-2.15-60.el6.x86_64.rpm nscd-2.15-60.el6.x86_64.rpm simple-obfs simple-obfs.tar.gz autoconf-2.69.tar.gz autoconf-2.69 autoconf-2.69.tar.gz.1
}
check_ss_ssr_ssrr_kcptun_installed(){
    ss_libev_installed_flag=""
    ssr_installed_flag=""
    ssrr_installed_flag=""
    kcptun_installed_flag=""
    kcptun_install_flag=""
    ss_libev_install_flag=""
    ssr_install_flag=""
    ssrr_install_flag=""
    if [ "${Install_Select}" == "1" ] || [ "${Install_Select}" == "4" ] || [ "${Update_Select}" == "1" ] || [ "${Update_Select}" == "5" ] || [ "${Uninstall_Select}" == "1" ] || [ "${Uninstall_Select}" == "5" ]; then
        if [[ "$(command -v "ss-server")" ]] || [[ "$(command -v "/usr/local/bin/ss-server")" ]]; then
            ss_libev_installed_flag="true"
        else
            ss_libev_installed_flag="false"
        fi
    fi
    if [ "${Install_Select}" == "2" ] || [ "${Install_Select}" == "5" ] || [ "${Update_Select}" == "2" ] || [ "${Update_Select}" == "5" ] || [ "${Uninstall_Select}" == "2" ] || [ "${Uninstall_Select}" == "5" ]; then
        if [[ -x /usr/local/shadowsocksR/shadowsocks/server.py ]] && [[ -s /usr/local/shadowsocksR/shadowsocks/__init__.py ]]; then
            ssr_installed_flag="true"
        else
            ssr_installed_flag="false"
        fi
    fi
    if [ "${Install_Select}" == "6" ] || [ "${Install_Select}" == "7" ] || [ "${Update_Select}" == "4" ] || [ "${Update_Select}" == "5" ] || [ "${Uninstall_Select}" == "4" ] || [ "${Uninstall_Select}" == "5" ]; then
        if [[ -x /usr/local/shadowsocksRR/shadowsocks/server.py ]] && [[ -s /usr/local/shadowsocksRR/shadowsocks/__init__.py ]]; then
            ssrr_installed_flag="true"
        else
            ssrr_installed_flag="false"
        fi
    fi
    if [ "${Install_Select}" == "3" ] || [ "${Install_Select}" == "4" ] || [ "${Install_Select}" == "5" ] || [ "${Install_Select}" == "7" ] || [ "${Update_Select}" == "3" ] || [ "${Update_Select}" == "5" ] || [ "${Uninstall_Select}" == "3" ] || [ "${Uninstall_Select}" == "5" ]; then
        if [[ "$(command -v "/usr/local/kcptun/kcptun")" ]] || [[ "$(command -v "kcptun")" ]]; then
            kcptun_installed_flag="true"
        else
            kcptun_installed_flag="false"
        fi
    fi
}
get_install_version(){
    rm -f ${cur_dir}/.version.sh
    if ! wget --no-check-certificate -qO ${cur_dir}/.version.sh ${program_version_link}; then
        echo -e "${COLOR_RED}Failed to download version.sh${COLOR_END}"
    fi
    if [ -s ${cur_dir}/.version.sh ]; then
        [ -x ${cur_dir}/.version.sh ] && chmod +x ${cur_dir}/.version.sh 
        . ${cur_dir}/.version.sh
    fi
    if [ -z ${LIBSODIUM_VER} ] || [ -z ${MBEDTLS_VER} ] || [ -z ${SS_LIBEV_VER} ] || [ -z ${SSR_VER} ] || [ -z ${SSRR_VER} ] || [ -z ${KCPTUN_VER} ]; then
        echo -e "${COLOR_RED}Error: Get Program version failed!${COLOR_END}"
        exit 1
    fi
}
get_latest_version(){
    rm -f ${cur_dir}/.api_*.txt 
    if [[ "${ss_libev_installed_flag}" == "false" && "${shell_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ss_libev_installed_flag}" == "true" && "${shell_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        echo -e "Loading Shadowsocks-libev version, please wait..."
        if check_sys packageManager yum; then
            ss_libev_init_link="${SS_LIBEV_YUM_INIT}"
        elif check_sys packageManager apt; then
            ss_libev_init_link="${SS_LIBEV_APT_INIT}"
        fi
        shadowsocks_libev_ver="shadowsocks-libev-${SS_LIBEV_VER}"
        if [[ "${ss_libev_installed_flag}" == "false" && "${shell_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
            echo -e "Get the Shadowsocks-libev version:${COLOR_GREEN} ${SS_LIBEV_VER}${COLOR_END}"
        fi
    fi
    if [ ! -f /usr/lib/libsodium.a ] && [ ! -L /usr/local/lib/libsodium.so ]; then
        echo -e "Loading libsodium version, please wait..."
        libsodium_laster_ver="libsodium-${LIBSODIUM_VER}"
        if [ "${libsodium_laster_ver}" == "" ] || [ "${LIBSODIUM_LINK}" == "" ]; then
            echo -e "${COLOR_RED}Error: Get libsodium version failed${COLOR_END}"
            exit 1
        fi
        echo -e "Get the libsodium version:${COLOR_GREEN} ${LIBSODIUM_VER}${COLOR_END}"
    fi
    if [ ! -f /usr/lib/libmbedtls.a ] && [ ! -f /usr/include/mbedtls/version.h ]; then
        echo -e "Loading mbedtls version, please wait..."
        mbedtls_laster_ver="mbedtls-${MBEDTLS_VER}"
        if [ "${mbedtls_laster_ver}" == "" ] || [ "${MBEDTLS_LINK}" == "" ]; then
            echo -e "${COLOR_RED}Error: Get mbedtls version failed${COLOR_END}"
            exit 1
        fi
        echo -e "Get the mbedtls version:${COLOR_GREEN} ${MBEDTLS_VER}${COLOR_END}"
    fi
    if [[ "${ssr_installed_flag}" == "false" && "${shell_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ssr_installed_flag}" == "true" && "${shell_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        echo -e "Loading ShadowsocksR version, please wait..."
        ssr_download_link="${SSR_LINK}"
        ssr_latest_ver="${SSR_VER}"
        if check_sys packageManager yum; then
            ssr_init_link="${SSR_YUM_INIT}"
        elif check_sys packageManager apt; then
            ssr_init_link="${SSR_APT_INIT}"
        fi
        if [[ "${ssr_installed_flag}" == "false" && "${shell_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
            echo -e "Get the ShadowsocksR version:${COLOR_GREEN} ${SSR_VER}${COLOR_END}"
        fi
    fi
    if [[ "${ssrr_installed_flag}" == "false" && "${shell_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ssrr_installed_flag}" == "true" && "${shell_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        echo -e "Loading ShadowsocksRR version, please wait..."
        ssrr_download_link="${SSRR_LINK}"
        ssrr_latest_ver="${SSRR_VER}"
        if check_sys packageManager yum; then
            ssrr_init_link="${SSRR_YUM_INIT}"
        elif check_sys packageManager apt; then
            ssrr_init_link="${SSRR_APT_INIT}"
        fi
        if [[ "${ssrr_installed_flag}" == "false" && "${shell_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
            echo -e "Get the ShadowsocksRR version:${COLOR_GREEN} ${SSRR_VER}${COLOR_END}"
        fi
    fi
    if [[ "${kcptun_installed_flag}" == "false" && "${shell_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${kcptun_installed_flag}" == "true" && "${shell_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        echo -e "Loading KCPTUN version, please wait..."
        kcptun_init_link="${KCPTUN_INIT}"
        kcptun_latest_file="kcptun-linux-${ARCHS}-${KCPTUN_VER}.tar.gz"
        if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
            kcptun_download_link="${KCPTUN_AMD64_LINK}"
        else
            kcptun_download_link="${KCPTUN_386_LINK}"
        fi
        if [[ "${kcptun_init_link}" == "" || "${kcptun_download_link}" == "" ]]; then
            echo -e "${COLOR_RED}Error: Get KCPTUN version failed${COLOR_END}"
            exit 1
        fi
        if [[ "${kcptun_installed_flag}" == "false" && "${shell_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
            echo -e "Get the KCPTUN version:${COLOR_GREEN} ${kcptun_latest_file}${COLOR_END}"
        fi
    fi
}
# Download latest
down_ss_ssr_ssrr_kcptun(){
    if [ ! -f /usr/lib/libsodium.a ] && [ ! -L /usr/local/lib/libsodium.so ]; then
        if [ -f ${libsodium_laster_ver}.tar.gz ]; then
            echo "${libsodium_laster_ver}.tar.gz [found]"
        else
            if ! wget --no-check-certificate -O ${libsodium_laster_ver}.tar.gz ${LIBSODIUM_LINK}; then
                echo -e "${COLOR_RED}Failed to download ${libsodium_laster_ver}.tar.gz${COLOR_END}"
                exit 1
            fi
        fi
    fi
    if [[ "${ss_libev_installed_flag}" == "false" && "${shell_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ss_libev_installed_flag}" == "true" && "${ss_libev_update_flag}" == "true" && "${shell_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        if [ -f ${shadowsocks_libev_ver}.tar.gz ]; then
            echo "${shadowsocks_libev_ver}.tar.gz [found]"
        else
            if ! wget --no-check-certificate -O ${shadowsocks_libev_ver}.tar.gz ${SS_LIBEV_LINK}; then
                echo -e "${COLOR_RED}Failed to download ${shadowsocks_libev_ver}.tar.gz${COLOR_END}"
                exit 1
            fi
        fi
        # Download init script
        if ! wget --no-check-certificate -O /etc/init.d/shadowsocks ${ss_libev_init_link}; then
            echo -e "${COLOR_RED}Failed to download Shadowsocks-libev init script!${COLOR_END}"
            exit 1
        fi
        if [ ! -f /usr/lib/libmbedtls.a ] && [ ! -f /usr/include/mbedtls/version.h ]; then
            if [ -f ${mbedtls_laster_ver}-gpl.tgz ]; then
                echo "${mbedtls_laster_ver}-gpl.tgz [found]"
            else
                if ! wget --no-check-certificate -O ${mbedtls_laster_ver}-gpl.tgz ${MBEDTLS_LINK}; then
                    echo -e "${COLOR_RED}Failed to download ${mbedtls_laster_ver}-gpl.tgz${COLOR_END}"
                    exit 1
                fi
            fi
        fi
    fi
    if [[ "${ssr_installed_flag}" == "false" && "${shell_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ssr_installed_flag}" == "true" && "${ssr_update_flag}" == "true" && "${shell_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        if [ -f manyuser.zip ]; then
            echo "manyuser.zip [found]"
        else
            if ! wget --no-check-certificate -O manyuser.zip ${ssr_download_link}; then
                echo -e "${COLOR_RED}Failed to download ShadowsocksR file!${COLOR_END}"
                exit 1
            fi
        fi
        if ! wget --no-check-certificate -O /etc/init.d/ssr ${ssr_init_link}; then
            echo -e "${COLOR_RED}Failed to download ShadowsocksR init script!${COLOR_END}"
            exit 1
        fi
    fi
    if [[ "${ssrr_installed_flag}" == "false" && "${shell_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ssrr_installed_flag}" == "true" && "${ssrr_update_flag}" == "true" && "${shell_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        if [ -f ssrr.zip ]; then
            echo "ssrr.zip [found]"
        else
            if ! wget --no-check-certificate -O ssrr.zip ${ssrr_download_link}; then
                echo -e "${COLOR_RED}Failed to download ShadowsocksRR file!${COLOR_END}"
                exit 1
            fi
        fi
        if ! wget --no-check-certificate -O /etc/init.d/ssrr ${ssrr_init_link}; then
            echo -e "${COLOR_RED}Failed to download ShadowsocksRR init script!${COLOR_END}"
            exit 1
        fi
    fi
    if [[ "${kcptun_installed_flag}" == "false" && "${shell_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${kcptun_installed_flag}" == "true" && "${kcptun_update_flag}" == "true" && "${shell_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        if [ -f ${kcptun_latest_file} ]; then
            echo "${kcptun_latest_file} [found]"
        else
            if ! wget --no-check-certificate -O ${kcptun_latest_file} ${kcptun_download_link}; then
                echo -e "${COLOR_RED}Failed to download ${kcptun_latest_file}${COLOR_END}"
                exit 1
            fi
        fi
        if ! wget --no-check-certificate -O /etc/init.d/kcptun ${kcptun_init_link}; then
            echo -e "${COLOR_RED}Failed to download KCPTUN init script!${COLOR_END}"
            exit 1
        fi
    fi
}
config_ss_ssr_ssrr_kcptun(){
    if check_kernel_version; then
        fast_open="true"
    else
        fast_open="false"
    fi
    if [[ "${ss_libev_installed_flag}" == "false" && "${shell_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
        [ ! -d /etc/shadowsocks-libev ] && mkdir -p /etc/shadowsocks-libev
        if [ "${Install_obfs}" == "y" ] || [ "${Install_obfs}" == "Y" ]; then
            cat > ${ss_libev_config}<<-EOF
{
    "server":"0.0.0.0",
    "server_port":${set_ss_libev_port},
    "local_address":"127.0.0.1",
    "local_port":${ss_libev_local_port},
    "password":"${set_ss_libev_pwd}",
    "timeout":300,
    "method":"${set_ss_libev_method}",
    "fast_open":${fast_open},
    "plugin":"obfs-server --obfs ${ofbs_option}"
}
EOF
        else
            cat > ${ss_libev_config}<<-EOF
{
    "server":"0.0.0.0",
    "server_port":${set_ss_libev_port},
    "local_address":"127.0.0.1",
    "local_port":${ss_libev_local_port},
    "password":"${set_ss_libev_pwd}",
    "timeout":300,
    "method":"${set_ss_libev_method}",
    "fast_open":${fast_open}
}
EOF
       fi
    fi
    if [[ "${ssr_installed_flag}" == "false" && "${shell_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
    [ ! -d /usr/local/shadowsocksR ] && mkdir -p /usr/local/shadowsocksR
    cat > ${ssr_config}<<-EOF
{
    "server":"0.0.0.0",
    "local_address":"127.0.0.1",
    "local_port":${ssr_local_port},
    "port_password":{
        "${set_ssr_port}":"${set_ssr_pwd}"
    },
    "timeout":300,
    "method":"${set_ssr_method}",
    "protocol":"${set_ssr_protocol}",
    "protocol_param":"",
    "obfs":"${set_ssr_obfs}",
    "obfs_param":"",
    "redirect":"",
    "dns_ipv6":false,
    "fast_open":${fast_open},
    "workers":1
}
EOF
    fi
    if [[ "${ssrr_installed_flag}" == "false" && "${shell_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
    [ ! -d /usr/local/shadowsocksRR ] && mkdir -p /usr/local/shadowsocksRR
    cat > ${ssrr_config}<<-EOF
{
    "server":"0.0.0.0",
    "server_ipv6":"::",
    "local_address":"127.0.0.1",
    "local_port":${ssrr_local_port},
    "port_password":{
        "${set_ssrr_port}":{"protocol":"${set_ssrr_protocol}", "protocol_param":"", "password":"${set_ssrr_pwd}", "obfs":"${set_ssrr_obfs}", "obfs_param":""}
    },
    "timeout":300,
    "method":"${set_ssrr_method}",
    "redirect": "",
    "dns_ipv6": false,
    "fast_open":${fast_open},
    "workers": 1
}
EOF
    fi
    if [[ "${kcptun_installed_flag}" == "false" && "${shell_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
        [ ! -d /usr/local/kcptun ] && mkdir -p /usr/local/kcptun
        # Config file
        cat > ${kcptun_config}<<-EOF
{
    "listen": ":${set_kcptun_port}",
    "target": "127.0.0.1:${kcptun_target_port}",
    "key": "${set_kcptun_pwd}",
    "crypt": "${set_kcptun_method}",
    "mode": "${set_kcptun_mode}",
    "mtu": ${set_kcptun_mtu},
    "sndwnd": 1024,
    "rcvwnd": 1024,
    "nocomp": ${set_kcptun_nocomp}
}
EOF
    fi
}
install_ss_ssr_ssrr_kcptun(){
    if [ ! -f /usr/lib/libsodium.a ] && [ ! -L /usr/local/lib/libsodium.so ]; then
        cd ${cur_dir}
	echo
        echo "+ Install libsodium for SS-Libev/SSR/SSRR/KCPTUN"
        tar xzf ${libsodium_laster_ver}.tar.gz
        cd ${libsodium_laster_ver}
        ./configure --prefix=/usr && make && make install
        if [ $? -ne 0 ]; then
            install_cleanup
            echo -e "${COLOR_RED}libsodium install failed!${COLOR_END}"
            exit 1
        fi
    ldconfig
    else
        echo -e "[${COLOR_GREED}libsodium already installed.${COLOR_END}"
    fi
    if [[ "${ss_libev_installed_flag}" == "false" && "${shell_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ss_libev_installed_flag}" == "true" && "${ss_libev_update_flag}" == "true" && "${shell_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        if [ ! -f /usr/lib/libmbedtls.a ]; then
            cd ${cur_dir}
	    echo
            echo "+ Install mbedtls for Shadowsocks-libev..."
            tar xzf ${mbedtls_laster_ver}-gpl.tgz
            cd ${mbedtls_laster_ver}
            make SHARED=1 CFLAGS=-fPIC
            make DESTDIR=/usr install
            if [ $? -ne 0 ]; then
                install_cleanup
                echo -e "${COLOR_RED}mbedtls install failed!${COLOR_END}"
                exit 1
            fi
            ldconfig
	      else
            echo -e "[${COLOR_GREED}mbedlts already installed.${COLOR_END}"
        fi
        cd ${cur_dir}
	echo
	echo "+ Shadowsocks-libev..."
        tar zxf ${shadowsocks_libev_ver}.tar.gz
        cd ${shadowsocks_libev_ver}
        ./configure --disable-documentation
        make && make install
        if [ $? -eq 0 ]; then
            chmod +x /etc/init.d/shadowsocks
            if check_sys packageManager yum; then
                chkconfig --add shadowsocks
                chkconfig shadowsocks on
            elif check_sys packageManager apt; then
                update-rc.d -f shadowsocks defaults
            fi
            if [ "${Install_obfs}" == "y" ] || [ "${Install_obfs}" == "Y" ]; then
	              install_simple_obfs
            fi
            # Run shadowsocks in the background
            /etc/init.d/shadowsocks start
            if [ $? -eq 0 ]; then
                [ -x /etc/init.d/shadowsocks ] && ln -s /etc/init.d/shadowsocks /usr/bin/shadowsocks
                echo -e "${COLOR_GREEN}Shadowsocks-libev start success!${COLOR_END}"
            else
                echo -e "${COLOR_RED}Shadowsocks-libev start failure!${COLOR_END}"
            fi
            ss_libev_install_flag="true"
        else
            install_cleanup
            echo
            echo -e "${COLOR_RED}Shadowsocks-libev install failed! ${COLOR_END}"
            exit 1
        fi
    fi
    if [[ "${ssr_installed_flag}" == "false" && "${shell_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ssr_installed_flag}" == "true" && "${ssr_update_flag}" == "true" && "${shell_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        cd ${cur_dir}
        unzip -qo manyuser.zip
        mv shadowsocksr-manyuser/shadowsocks/ /usr/local/shadowsocksR
        if [ -x /usr/local/shadowsocksR/shadowsocks/server.py ] && [ -s /usr/local/shadowsocksR/shadowsocks/__init__.py ]; then
            chmod +x /etc/init.d/ssr
            if check_sys packageManager yum; then
                chkconfig --add ssr
                chkconfig ssr on
            elif check_sys packageManager apt; then
                update-rc.d -f ssr defaults
            fi
            /etc/init.d/ssr start
            if [ $? -eq 0 ]; then
                [ -x /etc/init.d/ssr ] && ln -s /etc/init.d/ssr /usr/bin/ssr
                echo -e "${COLOR_GREEN}ShadowsocksR start success!${COLOR_END}"
            else
                echo -e "${COLOR_RED}ShadowsocksR start failure!${COLOR_END}"
            fi
            ssr_install_flag="true"
        else
            install_cleanup
            echo
            echo -e "${COLOR_RED}ShadowsocksR install failed!${COLOR_END}"
            exit 1
        fi
    fi
    if [[ "${ssrr_installed_flag}" == "false" && "${shell_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ssrr_installed_flag}" == "true" && "${ssrr_update_flag}" == "true" && "${shell_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        cd ${cur_dir}
        unzip -qo ssrr.zip
        mv shadowsocksr-akkariiin-master/* /usr/local/shadowsocksRR/
        if [ -x /usr/local/shadowsocksRR/shadowsocks/server.py ] && [ -s /usr/local/shadowsocksRR/shadowsocks/__init__.py ]; then
            chmod +x /etc/init.d/ssrr
            if check_sys packageManager yum; then
                chkconfig --add ssrr
                chkconfig ssrr on
            elif check_sys packageManager apt; then
                update-rc.d -f ssrr defaults
            fi
            /etc/init.d/ssrr start
            if [ $? -eq 0 ]; then
                [ -x /etc/init.d/ssrr ] && ln -s /etc/init.d/ssrr /usr/bin/ssrr
                echo -e "${COLOR_GREEN}ShadowsocksRR start success!${COLOR_END}"
            else
                echo -e "${COLOR_RED}ShadowsocksRR start failure!${COLOR_END}"
            fi
            ssrr_install_flag="true"
        else
            install_cleanup
            echo
            echo -e "${COLOR_RED}ShadowsocksRR install failed!${COLOR_END}"
            exit 1
        fi
    fi
    if [[ "${kcptun_installed_flag}" == "false" && "${shell_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${kcptun_installed_flag}" == "true" && "${kcptun_update_flag}" == "true" && "${shell_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        cd ${cur_dir}
        tar xzf ${kcptun_latest_file}
        [ ! -d /usr/local/kcptun ] && mkdir -p /usr/local/kcptun
        mv server_linux_${ARCHS} /usr/local/kcptun/kcptun
        rm -f ${kcptun_latest_file} client_linux_${ARCHS}
        chown root:root /usr/local/kcptun/*
        [ ! -x /usr/local/kcptun/kcptun ] && chmod 755 /usr/local/kcptun/kcptun
        /usr/local/kcptun/kcptun  --version
        if [ $? -eq 0 ]; then
            chmod +x /etc/init.d/kcptun
            if check_sys packageManager yum; then
                chkconfig --add kcptun
                chkconfig kcptun on
            elif check_sys packageManager apt; then
                update-rc.d -f kcptun defaults
            fi
            /etc/init.d/kcptun start
            if [ $? -eq 0 ]; then
                [ -x /etc/init.d/kcptun ] && ln -s /etc/init.d/kcptun /usr/bin/kcptun
                echo -e "${COLOR_GREEN}kcptun start success!${COLOR_END}"
            else
                echo -e "${COLOR_RED}kcptun start failure!${COLOR_END}"
            fi
            kcptun_install_flag="true"
        else
            install_cleanup
            echo
            echo -e "${COLOR_RED}kcptun install failed!${COLOR_END}"
            exit 1
        fi

    fi
    install_cleanup
}
install_simple_obfs(){
    cd ${cur_dir}
    if check_sys packageManager yum; then
        if centosversion 6; then
            update_autoconf
	          cd ${cur_dir}
	          wget --no-check-certificate -O simple-obfs.tar.gz https://raw.githubusercontent.com/Jenking-Zhang/shell_for_ss_ssr_ssrr_kcptun_bbr/master/centos6_simple-obfs.tar.gz
           tar -zxvpf simple-obfs.tar.gz
	         cd /root/simple-obfs
	         ./autogen.sh
           ./configure --disable-documentation
	         make
           make install
	         if [ ! "$(command -v obfs-server)" ]; then
               echo -e "[${COLOR_RED}Error:simple-obfs for Shadowsocks-libev install failed${COLOR_RED}"
               install_cleanup
               exit 1
           fi
           [ -f /usr/local/bin/obfs-server ] && ln -s /usr/local/bin/obfs-server /usr/bin
        else
	          git clone https://github.com/shadowsocks/simple-obfs.git
            cd simple-obfs
            git submodule update --init --recursive
            ./autogen.sh
            ./configure --disable-documentation
            make
            make install
	          if [ ! "$(command -v obfs-server)" ]; then
                echo -e "[${COLOR_RED}Error:simple-obfs for Shadowsocks-libev install failed${COLOR_RED}"
                install_cleanup
                exit 1
            fi
            [ -f /usr/local/bin/obfs-server ] && ln -s /usr/local/bin/obfs-server /usr/bin
       	fi
    elif check_sys packageManager apt; then
        git clone https://github.com/shadowsocks/simple-obfs.git
        cd simple-obfs
        git submodule update --init --recursive
        ./autogen.sh
        ./configure --disable-documentation
        make
        make install
        if [ ! "$(command -v obfs-server)" ]; then
            echo -e "[${COLOR_RED}Error:simple-obfs for Shadowsocks-libev install failed${COLOR_RED}"
            install_cleanup
            exit 1
        fi
        [ -f /usr/local/bin/obfs-server ] && ln -s /usr/local/bin/obfs-server /usr/bin
    fi
}
install_bbr(){
    if [ "${bbr_select}" == "1" ] ;then
        echo -e "+ Install BBR with Rinetd..."
        install_rinetd_bbr
    elif [ "${bbr_select}" == "2" ] ;then
        echo -e "+ Install BBR with LKL..."
        install_lkl_bbr
    fi
}
install_rinetd_bbr(){
    cd ${cur_dir}
    #Get Rinetd-BBR version.
    remote_bbr_version=$(wget --no-check-certificate -qO- https://api.github.com/repos/linhua55/lkl_study/releases/latest | grep 'tag_name' | cut -d\" -f4 | sed s/v//g )
    RINET_BBR_URL="https://github.com/linhua55/lkl_study/releases/download/v${remote_bbr_version}/rinetd_bbr_powered"
    BBR_INIT_URL="https://raw.githubusercontent.com/Jenking-Zhang/shell_for_ss_ssr_ssrr_kcptun_bbr/master/bbr.init"
    #Download Rinetd-BBR.
    echo -e "Get the Rinetd-BBR version:${COLOR_GREEN}${remote_bbr_version}${COLOR_END}"
    echo " Download Rinetd-BBR from $RINET_BBR_URL"
    curl -L "${RINET_BBR_URL}" >/usr/bin/rinetd-bbr
    chmod +x /usr/bin/rinetd-bbr
    #Config Rinetd-BBR.
    echo "Config Rinetd-BBR..."
    [ ! -d /etc/rinetd-bbr/ ] && mkdir /etc/rinetd-bbr/
    [ -d /etc/rinetd-bbr/bbr.conf ] && rm -rf /etc/rinetd-bbr/bbr.conf
    if [ ! -f rinetd_bbr.conf ];then
        mv rinetd_bbr.conf /etc/rinetd-bbr/bbr.conf
    else
    cat <<EOF > /etc/rinetd-bbr/bbr.conf
#bbr_version="${remote_bbr_version}"
# bindadress bindport connectaddress connectport
0.0.0.0 ${bbr_port} 0.0.0.0 ${bbr_port}
EOF
    fi
    #Config Rinetd-BBR service.
    echo "config Rinetd-BBR service..."
    wget --no-check-certificate "${BBR_INIT_URL}" -O /etc/init.d/bbr
    chmod +x /etc/init.d/bbr
    chkconfig --add bbr
    chkconfig bbr on
    /etc/init.d/bbr start
    if [ $? -eq 0 ]; then
        [ -x /etc/init.d/bbr ] && ln -s /etc/init.d/bbr /usr/bin/rinetd-bbr
        echo -e "${COLOR_GREEN}Rinetd-BBR start success!${COLOR_END}"
    else
        echo -e "${COLOR_RED}Rinetd-BBR start failure!${COLOR_END}"
    fi
}
install_lkl_bbr(){
    cd ${cur_dir}
    wget --no-check-certificate https://raw.githubusercontent.com/Jenking-Zhang/shell_for_ss_ssr_ssrr_kcptun_bbr/master/ovz-bbr-installer.sh
    chmod +x ovz-bbr-installer.sh
    ./ovz-bbr-installer.sh
}
set_crontab(){
    if check_sys packageManager yum; then
        if centosversion 6; then
            echo -e "+ Set crontab..."
	    yum install -y cronie
            chkconfig crond on
            service crond start
	    echo "27 3 * * 2,5 /sbin/reboot" >> /var/spool/cron/root
	    if [ "${Install_Select}" == "1" ] || [ "${Install_Select}" == "4" ]; then echo "28 3 * * * /etc/init.d/shadowsocks restart" >> /var/spool/cron/root; fi
	    if [ "${Install_Select}" == "2" ] || [ "${Install_Select}" == "5" ]; then echo "28 3 * * * /etc/init.d/ssr restart" >> /var/spool/cron/root; fi
	    if [ "${Install_Select}" == "6" ] || [ "${Install_Select}" == "7" ]; then echo "28 3 * * * /etc/init.d/ssrr restart" >> /var/spool/cron/root; fi
	    if [ "${Install_Select}" == "3" ] || [ "${Install_Select}" == "4" ] || [ "${Install_Select}" == "5" ] || [ "${Install_Select}" == "7" ]; then echo "29 3 * * * /etc/init.d/kcptun restart" >> /var/spool/cron/root; fi
	    if [ "${bbr_select}" == "1" ] ;then
	        echo "29 3 * * * /etc/init.d/bbr restart" >> /var/spool/cron/root
            elif [ "${bbr_select}" == "2" ] ;then
                echo "29 3 * * * service haproxy-lkl restart" >> /var/spool/cron/root
            fi
            service crond restart
        fi
    elif check_sys packageManager apt; then
        echo -e "+ Set crontab..."
	apt-get install cron -y
        /etc/init.d/cron start
        echo "27 3 * * 2,5 /sbin/reboot" >> /var/spool/cron/crontabs/root
        if [ "${Install_Select}" == "1" ] || [ "${Install_Select}" == "4" ]; then echo "28 3 * * * /etc/init.d/shadowsocks restart" >> /var/spool/cron/crontabs/root; fi
        if [ "${Install_Select}" == "2" ] || [ "${Install_Select}" == "5" ]; then echo "28 3 * * * /etc/init.d/ssr restart" >> /var/spool/cron/crontabs/root; fi
        if [ "${Install_Select}" == "6" ] || [ "${Install_Select}" == "7" ]; then echo "28 3 * * * /etc/init.d/ssrr restart" >> /var/spool/cron/crontabs/root; fi
        if [ "${Install_Select}" == "3" ] || [ "${Install_Select}" == "4" ] || [ "${Install_Select}" == "5" ] || [ "${Install_Select}" == "7" ]; then echo "29 3 * * * /etc/init.d/kcptun restart" >> /var/spool/cron/crontabs/root; fi
        if [ "${bbr_select}" == "1" ] ;then
            echo "29 3 * * * /etc/init.d/bbr restart" >> /var/spool/cron/crontabs/root
        elif [ "${bbr_select}" == "2" ] ;then
            echo "29 3 * * * service haproxy-lkl restart" >> /var/spool/cron/crontabs/root
        fi
        /etc/init.d/cron restart
    fi
}
# Firewall set
firewall_set(){
    if [ "${kcptun_install_flag}" == "true" ] || [ "${ss_libev_install_flag}" == "true" ] || [ "${ssr_install_flag}" == "true" ] || [ "${ssrr_install_flag}" == "true" ]; then
        echo "+ firewall set start..."
        firewall_set_flag="false"
        if centosversion 6; then
            /etc/init.d/iptables status > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                if [ "${ss_libev_install_flag}" == "true" ]; then
                    iptables -L -n | grep -i ${set_ss_libev_port} > /dev/null 2>&1
                    if [ $? -ne 0 ]; then
                        iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${set_ss_libev_port} -j ACCEPT
                        iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${set_ss_libev_port} -j ACCEPT
                        firewall_set_flag="true"
                    else
                        echo "+ port ${set_ss_libev_port} has been set up."
                    fi
                fi
                if [ "${ssr_install_flag}" == "true" ]; then
                    iptables -L -n | grep -i ${set_ssr_port} > /dev/null 2>&1
                    if [ $? -ne 0 ]; then
                        iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${set_ssr_port} -j ACCEPT
                        iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${set_ssr_port} -j ACCEPT
                        firewall_set_flag="true"
                    else
                        echo "+ port ${set_ssr_port} has been set up."
                    fi
                fi
                if [ "${ssrr_install_flag}" == "true" ]; then
                    iptables -L -n | grep -i ${set_ssrr_port} > /dev/null 2>&1
                    if [ $? -ne 0 ]; then
                        iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${set_ssrr_port} -j ACCEPT
                        iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${set_ssrr_port} -j ACCEPT
                        firewall_set_flag="true"
                    else
                        echo "+ port ${set_ssrr_port} has been set up."
                    fi
                fi
                if [ "${kcptun_install_flag}" == "true" ]; then
                    iptables -L -n | grep -i ${set_kcptun_port} > /dev/null 2>&1
                    if [ $? -ne 0 ]; then
                        iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${set_kcptun_port} -j ACCEPT
                        firewall_set_flag="true"
                    else
                        echo "+ port ${set_kcptun_port} has been set up."
                    fi
                fi
                if [ "${firewall_set_flag}" == "true" ]; then
                    /etc/init.d/iptables save
                    /etc/init.d/iptables restart
                fi
            else
                echo "WARNING: iptables looks like shutdown or not installed, please manually set it if necessary."
            fi
        elif centosversion 7; then
            systemctl status firewalld > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                if [ "${ss_libev_install_flag}" == "true" ]; then
                    firewall-cmd --permanent --zone=public --add-port=${set_ss_libev_port}/tcp
                    firewall-cmd --permanent --zone=public --add-port=${set_ss_libev_port}/udp
                    firewall_set_flag="true"
                fi
                if [ "${ssr_install_flag}" == "true" ]; then
                    firewall-cmd --permanent --zone=public --add-port=${set_ssr_port}/tcp
                    firewall-cmd --permanent --zone=public --add-port=${set_ssr_port}/udp
                    firewall_set_flag="true"
                fi
                if [ "${ssrr_install_flag}" == "true" ]; then
                    firewall-cmd --permanent --zone=public --add-port=${set_ssrr_port}/tcp
                    firewall-cmd --permanent --zone=public --add-port=${set_ssrr_port}/udp
                    firewall_set_flag="true"
                fi
                if [ "${kcptun_install_flag}" == "true" ]; then
                    firewall-cmd --permanent --zone=public --add-port=${set_kcptun_port}/udp
                    firewall_set_flag="true"
                fi
                if [ "${firewall_set_flag}" == "true" ]; then
                    firewall-cmd --reload
                fi
            else
                echo "+ Firewalld looks like not running, try to start..."
                systemctl start firewalld
                if [ $? -eq 0 ]; then
                    if [ "${ss_libev_install_flag}" == "true" ]; then
                        firewall-cmd --permanent --zone=public --add-port=${set_ss_libev_port}/tcp
                        firewall-cmd --permanent --zone=public --add-port=${set_ss_libev_port}/udp
                        firewall_set_flag="true"
                    fi
                    if [ "${ssr_install_flag}" == "true" ]; then
                        firewall-cmd --permanent --zone=public --add-port=${set_ssr_port}/tcp
                        firewall-cmd --permanent --zone=public --add-port=${set_ssr_port}/udp
                        firewall_set_flag="true"
                    fi
                    if [ "${ssrr_install_flag}" == "true" ]; then
                        firewall-cmd --permanent --zone=public --add-port=${set_ssrr_port}/tcp
                        firewall-cmd --permanent --zone=public --add-port=${set_ssrr_port}/udp
                        firewall_set_flag="true"
                    fi
                    if [ "${kcptun_install_flag}" == "true" ]; then
                        firewall-cmd --permanent --zone=public --add-port=${set_kcptun_port}/udp
                        firewall_set_flag="true"
                    fi
                    if [ "${firewall_set_flag}" == "true" ]; then
                        firewall-cmd --reload
                    fi
                else
                    echo "WARNING: Try to start firewalld failed. please enable port manually if necessary."
                fi
            fi
        fi
        echo "+ firewall set completed..."
    fi
}
show_ss_ssr_ssr_kcptun(){
    echo
    if [ "${kcptun_install_flag}" == "true" ] || [ "${ss_libev_install_flag}" == "true" ] || [ "${ssr_install_flag}" == "true" ] || [ "${ssrr_install_flag}" == "true" ]; then
        SERVER_IP=$(get_ip)
        
        echo "Congratulations, install completed!"
        echo -e "========================= Your Server Setting ========================="
        echo -e "Your Server IP: ${COLOR_GREEN}${SERVER_IP}${COLOR_END}"
    fi
    if [ "${ss_libev_install_flag}" == "true" ]; then
        echo "-------------------- Shadowsocks-libev Setting --------------------"
        echo -e "SS-libev configure file    : ${COLOR_GREEN}${ss_libev_config}${COLOR_END}"
        echo -e "SS-libev Server Port       : ${COLOR_GREEN}${set_ss_libev_port}${COLOR_END}"
        echo -e "SS-libev Password          : ${COLOR_GREEN}${set_ss_libev_pwd}${COLOR_END}"
        echo -e "SS-libev Encryption Method : ${COLOR_GREEN}${set_ss_libev_method}${COLOR_END}"
        #echo -e "SS-libev Local IP          : ${COLOR_GREEN}127.0.0.1${COLOR_END}"
        #echo -e "SS-libev Local Port        : ${COLOR_GREEN}${ss_libev_local_port}${COLOR_END}"
        if [ "${Install_obfs}" == "y" ] || [ "${Install_obfs}" == "Y" ]; then
            echo -e "SS-libev obfs              : ${COLOR_GREEN}obfs-server --obfs ${ofbs_option}${COLOR_END}"
        fi
        echo "----------------------------------------------------------"
        echo -e "SS-libev status manage: ${COLOR_PINK}/etc/init.d/shadowsocks${COLOR_END} {${COLOR_GREEN}start|stop|restart|status|config|viewconfig|version${COLOR_END}}"
        echo "=========================================================="
    fi
    if [ "${ssr_install_flag}" == "true" ]; then
        echo "-------------------- ShadowsocksR Setting --------------------"
        echo -e "SSR configure file         : ${COLOR_GREEN}${ssr_config}${COLOR_END}"
        echo -e "SSR Server Port            : ${COLOR_GREEN}${set_ssr_port}${COLOR_END}"
        echo -e "SSR Password               : ${COLOR_GREEN}${set_ssr_pwd}${COLOR_END}"
        echo -e "SSR Encryption Method      : ${COLOR_GREEN}${set_ssr_method}${COLOR_END}"
        echo -e "SSR protocol               : ${COLOR_GREEN}${set_ssr_protocol}${COLOR_END}"
        echo -e "SSR obfs                   : ${COLOR_GREEN}${set_ssr_obfs}${COLOR_END}"
        #echo -e "SSR Local IP               : ${COLOR_GREEN}127.0.0.1${COLOR_END}"
        #echo -e "SSR Local Port             : ${COLOR_GREEN}${ssr_local_port}${COLOR_END}"
        echo "----------------------------------------------------------"
        echo -e "SSR status manage: ${COLOR_PINK}/etc/init.d/ssr${COLOR_END} {${COLOR_GREEN}start|stop|restart|status|config|viewconfig|version${COLOR_END}}"
        echo "=========================================================="
    fi
    if [ "${ssrr_install_flag}" == "true" ]; then
        echo "-------------------- ShadowsocksRR Setting --------------------"
        echo -e "SSRR configure file         : ${COLOR_GREEN}${ssrr_config}${COLOR_END}"
        echo -e "SSRR Server Port            : ${COLOR_GREEN}${set_ssrr_port}${COLOR_END}"
        echo -e "SSRR Password               : ${COLOR_GREEN}${set_ssrr_pwd}${COLOR_END}"
        echo -e "SSRR Encryption Method      : ${COLOR_GREEN}${set_ssrr_method}${COLOR_END}"
        echo -e "SSRR protocol               : ${COLOR_GREEN}${set_ssrr_protocol}${COLOR_END}"
        echo -e "SSRR obfs                   : ${COLOR_GREEN}${set_ssrr_obfs}${COLOR_END}"
        #echo -e "SSRR Local IP               : ${COLOR_GREEN}127.0.0.1${COLOR_END}"
        #echo -e "SSRR Local Port             : ${COLOR_GREEN}${ssrr_local_port}${COLOR_END}"
        echo "----------------------------------------------------------"
        echo -e "SSRR status manage: ${COLOR_PINK}/etc/init.d/ssrr${COLOR_END} {${COLOR_GREEN}start|stop|restart|status|config|viewconfig|version${COLOR_END}}"
        echo "=========================================================="
    fi
    if [ "${kcptun_install_flag}" == "true" ]; then
        echo "-------------------- KCPTUN Setting --------------------"
        echo -e "KCPTUN configure file     : ${COLOR_GREEN}${kcptun_config}${COLOR_END}"
        echo -e "KCPTUN Server Port        : ${COLOR_GREEN}${set_kcptun_port}${COLOR_END}"
        echo -e "KCPTUN Key                : ${COLOR_GREEN}${set_kcptun_pwd}${COLOR_END}"
        echo -e "KCPTUN Crypt mode         : ${COLOR_GREEN}${set_kcptun_method}${COLOR_END}"
        echo -e "KCPTUN Fast mode          : ${COLOR_GREEN}${set_kcptun_mode}${COLOR_END}"
        echo -e "KCPTUN MTU                : ${COLOR_GREEN}${set_kcptun_mtu}${COLOR_END}"
        echo -e "KCPTUN sndwnd             : ${COLOR_GREEN}1024${COLOR_END}"
        echo -e "KCPTUN rcvwnd             : ${COLOR_GREEN}1024${COLOR_END}"
        echo -e "KCPTUN compression        : ${COLOR_GREEN}${set_kcptun_compression}${COLOR_END}"
        echo "----------------------------------------------------------"
        echo -e "${COLOR_PINK}Kcptun config for SS/SSR/Phone:${COLOR_END}"
        echo -e "KCP Port      : ${COLOR_GREEN}${set_kcptun_port}${COLOR_END}"
        echo -e "KCP parameter : ${COLOR_GREEN}--crypt ${set_kcptun_method} --key ${set_kcptun_pwd} --mtu ${set_kcptun_mtu} --sndwnd 128 --rcvwnd 1024 --mode ${set_kcptun_mode}${show_kcptun_nocomp}${COLOR_END}"
        echo "----------------------------------------------------------"
        echo -e "KCPTUN status manage: ${COLOR_PINK}/etc/init.d/kcptun${COLOR_END} {${COLOR_GREEN}start|stop|restart|status|config|viewconfig|version${COLOR_END}}"
        echo "=========================================================="
    fi
    echo
}
pre_install_ss_ssr_ssrr_kcptun(){
    clear
    Dispaly_Selection
    Simple_obfs_option
    BBR_Selection
    BBR_option
    Press_Install
    pre_install_packs
    get_install_version
    Print_Sys_Info
    set_timezone
    Disable_Selinux
    check_ss_ssr_ssrr_kcptun_installed
    cd ${cur_dir}
    ###############################   Shadowsocks-libev   ###############################
    if [ "${ss_libev_installed_flag}" == "false" ]; then
        echo
        echo "=========================================================="
        echo -e "${COLOR_PINK}Please input your Shadowsocks-libev setting:${COLOR_END}"
        echo
        # Set Shadowsocks-libev password
        def_ss_libev_pwd=`randstr`
        echo "Please input password for Shadowsocks-libev"
        #read -p "(Default password: ${def_ss_libev_pwd}):" set_ss_libev_pwd
        [ -z "${set_ss_libev_pwd}" ] && set_ss_libev_pwd="${def_ss_libev_pwd}"
        echo
        echo "---------------------------------------"
        echo "Shadowsocks-libev password = ${set_ss_libev_pwd}"
        echo "---------------------------------------"
        echo
        # Set shadowsocks-libev port
        while true
        do
            def_ss_libev_port="8989"
            echo -e "Please input port for Shadowsocks-libev [1-65535]"
            #read -p "(Default port: ${def_ss_libev_port}):" set_ss_libev_port
            [ -z "$set_ss_libev_port" ] && set_ss_libev_port="${def_ss_libev_port}"
            expr ${set_ss_libev_port} + 0 &>/dev/null
            if [ $? -eq 0 ]; then
                if [ ${set_ss_libev_port} -ge 1 ] && [ ${set_ss_libev_port} -le 65535 ]; then
                    echo
                    echo "---------------------------------------"
                    echo "Shadowsocks-libev port = ${set_ss_libev_port}"
                    echo "---------------------------------------"
                    echo
                    break
                else
                    echo "Input error, please input correct number"
                fi
            else
                echo "Input error, please input correct number"
            fi
        done
        ss_libev_local_port="1086"
        def_ss_libev_method="aes-256-gcm"
        echo -e "Please select method for Shadowsocks-libev"
        echo "  1: rc4-md5"
        echo "  2: aes-128-gcm"
        echo "  3: aes-192-gcm"
        echo "  4: aes-256-gcm (default)"
        echo "  5: aes-128-cfb"
        echo "  6: aes-192-cfb"
        echo "  7: aes-256-cfb"
        echo "  8: aes-128-ctr"
        echo "  9: aes-192-ctr"
        echo " 10: aes-256-ctr"
        echo " 11: camellia-128-cfb"
        echo " 12: camellia-192-cfb"
        echo " 13: camellia-256-cfb"
        echo " 14: bf-cfb"
        echo " 15: chacha20-ietf-poly1305"
        echo " 16: salsa20"
        echo " 17: chacha20"
        echo " 18: chacha20-ietf"
        #read -p "Enter your choice (1, 2, 3, ... or exit. default [${def_ss_libev_method}]): " set_ss_libev_method
        case "${set_ss_libev_method}" in
            1|[Rr][Cc]4-[Mm][Dd]5)
                set_ss_libev_method="rc4-md5"
                ;;
            2|[Aa][Ee][Ss]-128-[Gg][Cc][Mm])
                set_ss_libev_method="aes-128-gcm"
                ;;
            3|[Aa][Ee][Ss]-192-[Gg][Cc][Mm])
                set_ss_libev_method="aes-192-gcm"
                ;;
            4|[Aa][Ee][Ss]-256-[Gg][Cc][Mm])
                set_ss_libev_method="aes-256-gcm"
                ;;
            5|[Aa][Ee][Ss]-128-[Cc][Ff][Bb])
                set_ss_libev_method="aes-128-cfb"
                ;;
            6|[Aa][Ee][Ss]-192-[Cc][Ff][Bb])
                set_ss_libev_method="aes-192-cfb"
                ;;
            7|[Aa][Ee][Ss]-256-[Cc][Ff][Bb])
                set_ss_libev_method="aes-256-cfb"
                ;;
            8|[Aa][Ee][Ss]-128-[Cc][Tt][Rr])
                set_ss_libev_method="aes-128-ctr"
                ;;
            9|[Aa][Ee][Ss]-192-[Cc][Tt][Rr])
                set_ss_libev_method="aes-192-ctr"
                ;;
            10|[Aa][Ee][Ss]-256-[Cc][Tt][Rr])
                set_ss_libev_method="aes-256-ctr"
                ;;
            11|[Cc][Aa][Mm][Ee][Ll][Ll][Ii][Aa]-128-[Cc][Ff][Bb])
                set_ss_libev_method="camellia-128-cfb"
                ;;
            12|[Cc][Aa][Mm][Ee][Ll][Ll][Ii][Aa]-192-[Cc][Ff][Bb])
                set_ss_libev_method="camellia-192-cfb"
                ;;
            13|[Cc][Aa][Mm][Ee][Ll][Ll][Ii][Aa]-256-[Cc][Ff][Bb])
                set_ss_libev_method="camellia-256-cfb"
                ;;
            14|[Bb][Ff]-[Cc][Ff][Bb])
                set_ss_libev_method="bf-cfb"
                ;;
            15|[Cc][Hh][Aa][Cc][Hh][Aa]20-[Ii][Ee][Tt][Ff]-[Pp][Oo][Ll][Yy]1305)
                set_ss_libev_method="chacha20-ietf-poly1305"
                ;;
            16|[Ss][Aa][Ll][As][Aa]20)
                set_ss_libev_method="salsa20"
                ;;
            17|[Cc][Hh][Aa][Cc][Hh][Aa]20)
                set_ss_libev_method="chacha20"
                ;;
            18|[Cc][Hh][Aa][Cc][Hh][Aa]20-[Ii][Ee][Tt][Ff])
                set_ss_libev_method="chacha20-ietf"
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                set_ss_libev_method="${def_ss_libev_method}"
                ;;
        esac
        echo
        echo "---------------------------------------"
        echo "Shadowsocks-libev method: ${set_ss_libev_method}"
        echo "---------------------------------------"
        echo
        echo "=========================================================="
    elif [ "${ss_libev_installed_flag}" == "true" ]; then
        echo
        echo -e "${COLOR_PINK}Shadowsocks-libev has been installed, nothing to do...${COLOR_END}"
        [ "${Install_Select}" == "1" ] && exit 0
    fi
    ###############################   ShadowsocksR   ###############################
    if [ "${ssr_installed_flag}" == "false" ]; then
        echo
        echo "=========================================================="
        echo -e "${COLOR_PINK}Please input your ShadowsocksR(SSR) setting:${COLOR_END}"
        echo
        # Set shadowsocksR password
        def_ssr_pwd=`randstr`
        echo "Please input password for ShadowsocksR"
        #read -p "(Default password: ${def_ssr_pwd}):" set_ssr_pwd
        [ -z "${set_ssr_pwd}" ] && set_ssr_pwd="${def_ssr_pwd}"
        echo
        echo "---------------------------------------"
        echo "SSR password = ${set_ssr_pwd}"
        echo "---------------------------------------"
        echo
        # Set shadowsocksR port
        while true
        do
            def_ssr_port="28989"
            echo -e "Please input port for ShadowsocksR [1-65535]"
            #read -p "(Default port: ${def_ssr_port}):" set_ssr_port
            [ -z "$set_ssr_port" ] && set_ssr_port="${def_ssr_port}"
            expr ${set_ssr_port} + 0 &>/dev/null
            if [ $? -eq 0 ]; then
                if [ ${set_ssr_port} -ge 1 ] && [ ${set_ssr_port} -le 65535 ]; then
                    echo
                    echo "---------------------------------------"
                    echo "SSR port = ${set_ssr_port}"
                    echo "---------------------------------------"
                    echo
                    break
                else
                    echo "Input error, please input correct number"
                fi
            else
                echo "Input error, please input correct number"
            fi
        done
        ssr_local_port="1088"
        #mujson_mgr.py
        def_ssr_method="aes-256-cfb"
        echo -e "Please select encryption method for ShadowsocksR"
        echo "  0: none"
        echo "  1: aes-128-cfb"
        echo "  2: aes-192-cfb"
        echo "  3: aes-256-cfb (default)"
        echo "  4: rc4-md5"
        echo "  5: rc4-md5-6"
        echo "  6: chacha20"
        echo "  7: chacha20-ietf"
        echo "  8: salsa20"
        echo "  9: aes-128-ctr"
        echo " 10: aes-192-ctr"
        echo " 11: aes-256-ctr"
        #read -p "Enter your choice (0, 1, 2, 3, ... or exit. default [${def_ssr_method}]): " set_ssr_method
        case "${set_ssr_method}" in
            0|[Nn][Oo][Nn][Ee])
                set_ssr_method="none"
                ;;
            1|[Aa][Ee][Ss]-128-[Cc][Ff][Bb])
                set_ssr_method="aes-128-cfb"
                ;;
            2|[Aa][Ee][Ss]-192-[Cc][Ff][Bb])
                set_ssr_method="aes-192-cfb"
                ;;
            3|[Aa][Ee][Ss]-256-[Cc][Ff][Bb])
                set_ssr_method="aes-256-cfb"
                ;;
            4|[Rr][Cc]4-[Mm][Dd]5)
                set_ssr_method="rc4-md5"
                ;;
            5|[Rr][Cc]4-[Mm][Dd]5-6)
                set_ssr_method="rc4-md5-6"
                ;;
            6|[Cc][Hh][Aa][Cc][Hh][Aa]20)
                set_ssr_method="chacha20"
                ;;
            7|[Cc][Hh][Aa][Cc][Hh][Aa]20-[Ii][Ee][Tt][Ff])
                set_ssr_method="chacha20-ietf"
                ;;
            8|[Ss][Aa][Ll][As][Aa]20)
                set_ssr_method="salsa20"
                ;;
            9|[Aa][Ee][Ss]-128-[Cc][Tt][Rr])
                set_ssr_method="aes-128-ctr"
                ;;
            10|[Aa][Ee][Ss]-192-[Cc][Tt][Rr])
                set_ssr_method="aes-192-ctr"
                ;;
            11|[Aa][Ee][Ss]-256-[Cc][Tt][Rr])
                set_ssr_method="aes-256-ctr"
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                set_ssr_method="${def_ssr_method}"
                ;;
        esac
        echo
        echo "---------------------------------------"
        echo "SSR method: ${set_ssr_method}"
        echo "---------------------------------------"
        echo
        def_ssr_protocol="origin"
        echo -e "Please select Protocol plugin for ShadowsocksR"
        echo "  1: origin (default)"
        echo "  2: auth_sha1_v4"
        echo "  3: auth_sha1_v4_compatible"
        echo "  4: auth_aes128_md5"
        echo "  5: auth_aes128_sha1"
        echo "  6: auth_chain_a"
        #read -p "Enter your choice (1, 2, 3, ... or exit. default [${def_ssr_protocol}]): " set_ssr_protocol
        case "${set_ssr_protocol}" in
            1|[Oo][Rr][Ii][Gg][Ii][Nn])
                set_ssr_protocol="origin"
                ;;
            2|[Aa][Uu][Tt][Hh]_[Ss][Hh][Aa]1_[Vv]4)
                set_ssr_protocol="auth_sha1_v4"
                ;;
            3|[Aa][Uu][Tt][Hh]_[Ss][Hh][Aa]1_[Vv]4_[Cc][Oo][Mm][Pp][Aa][Tt][Ii][Bb][Ll][Ee])
                set_ssr_protocol="auth_sha1_v4_compatible"
                ;;
            4|[Aa][Uu][Tt][Hh]_[Aa][Ee][Ss]128_[Mm][Dd]5)
                set_ssr_protocol="auth_aes128_md5"
                ;;
            5|[Aa][Uu][Tt][Hh]_[Aa][Ee][Ss]128_[Ss][Hh][Aa]5)
                set_ssr_protocol="auth_aes128_sha1"
                ;;
            6|[Aa][Uu][Tt][Hh]_[Cc][Hh][Aa][Ii][Nn]_[Aa])
                set_ssr_protocol="auth_chain_a"
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                set_ssr_protocol="${def_ssr_protocol}"
                ;;
        esac
        echo
        echo "---------------------------------------"
        echo "SSR Protocol: ${set_ssr_protocol}"
        echo "---------------------------------------"
        echo
        def_ssr_obfs="plain"
        echo -e "Please select Obfs plugin for ShadowsocksR"
        echo "  1: plain (default)"
        echo "  2: http_simple_compatible"
        echo "  3: http_simple"
        echo "  4: tls1.2_ticket_auth_compatible"
        echo "  5: tls1.2_ticket_auth"
        #read -p "Enter your choice (1, 2, 3, ... or exit. default [${def_ssr_obfs}]): " set_ssr_obfs
        case "${set_ssr_obfs}" in
            1|[Pp][Ll][Aa][Ii][Nn])
                set_ssr_obfs="plain"
                ;;
            2|[Hh][Tt][Tt][Pp]_[Ss][Ii][Mm][Pp][Ll][Ee]_[Cc][Oo][Mm][Pp][Aa][Tt][Ii][Bb][Ll][Ee])
                set_ssr_obfs="http_simple_compatible"
                ;;
            3|[Hh][Tt][Tt][Pp]_[Ss][Ii][Mm][Pp][Ll][Ee])
                set_ssr_obfs="http_simple"
                ;;
            4|[Tt][Ll][Ss]1.2_[Tt][Ii][Cc][Kk][Ee][Tt]_[Aa][Uu][Tt][Hh]_[Cc][Oo][Mm][Pp][Aa][Tt][Ii][Bb][Ll][Ee])
                set_ssr_obfs="tls1.2_ticket_auth_compatible"
                ;;
            5|[Tt][Ll][Ss]1.2_[Tt][Ii][Cc][Kk][Ee][Tt]_[Aa][Uu][Tt][Hh])
                set_ssr_obfs="tls1.2_ticket_auth"
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                set_ssr_obfs="${def_ssr_obfs}"
                ;;
        esac
        echo
        echo "---------------------------------------"
        echo "SSR obfs: ${set_ssr_obfs}"
        echo "---------------------------------------"
        echo
        echo "=========================================================="
    elif [ "${ssr_installed_flag}" == "true" ]; then
        echo
        echo -e "${COLOR_PINK}ShadowsocksR has been installed, nothing to do...${COLOR_END}"
        [ "${Install_Select}" == "2" ] && exit 0
    fi
    ###############################   shadowsocksRR   ###############################
    if [ "${ssrr_installed_flag}" == "false" ]; then
        echo
        echo "=========================================================="
        echo -e "${COLOR_PINK}Please input your ShadowsocksRR(SSRR) setting:${COLOR_END}"
        echo
        # Set shadowsocksRR password
        def_ssrr_pwd=`randstr`
        echo "Please input password for ShadowsocksRR"
        #read -p "(Default password: ${def_ssrr_pwd}):" set_ssrr_pwd
        [ -z "${set_ssrr_pwd}" ] && set_ssrr_pwd="${def_ssrr_pwd}"
        echo
        echo "---------------------------------------"
        echo "SSRR password = ${set_ssrr_pwd}"
        echo "---------------------------------------"
        echo
        # Set shadowsocksRR port
        while true
        do
            def_ssrr_port="48989"
            echo -e "Please input port for ShadowsocksRR [1-65535]"
            #read -p "(Default port: ${def_ssrr_port}):" set_ssrr_port
            [ -z "$set_ssrr_port" ] && set_ssrr_port="${def_ssrr_port}"
            expr ${set_ssrr_port} + 0 &>/dev/null
            if [ $? -eq 0 ]; then
                if [ ${set_ssrr_port} -ge 1 ] && [ ${set_ssrr_port} -le 65535 ]; then
                    echo
                    echo "---------------------------------------"
                    echo "SSRR port = ${set_ssrr_port}"
                    echo "---------------------------------------"
                    echo
                    break
                else
                    echo "Input error, please input correct number"
                fi
            else
                echo "Input error, please input correct number"
            fi
        done
        ssrr_local_port="1089"
        #mujson_mgr.py
        def_ssrr_method="aes-256-cfb"
        echo -e "Please select encryption method for ShadowsocksRR"
        echo "  0: none"
        echo "  1: aes-128-cfb"
        echo "  2: aes-192-cfb"
        echo "  3: aes-256-cfb (default)"
        echo "  4: rc4-md5"
        echo "  5: rc4-md5-6"
        echo "  6: chacha20"
        echo "  7: chacha20-ietf"
        echo "  8: salsa20"
        echo "  9: aes-128-ctr"
        echo " 10: aes-192-ctr"
        echo " 11: aes-256-ctr"
        echo " 12: xsalsa20"
        echo " 13: xchacha20"
        #read -p "Enter your choice (0, 1, 2, 3, ... or exit. default [${def_ssrr_method}]): " set_ssrr_method
        case "${set_ssrr_method}" in
            0|[Nn][Oo][Nn][Ee])
                set_ssrr_method="none"
                ;;
            1|[Aa][Ee][Ss]-128-[Cc][Ff][Bb])
                set_ssrr_method="aes-128-cfb"
                ;;
            2|[Aa][Ee][Ss]-192-[Cc][Ff][Bb])
                set_ssrr_method="aes-192-cfb"
                ;;
            3|[Aa][Ee][Ss]-256-[Cc][Ff][Bb])
                set_ssrr_method="aes-256-cfb"
                ;;
            4|[Rr][Cc]4-[Mm][Dd]5)
                set_ssrr_method="rc4-md5"
                ;;
            5|[Rr][Cc]4-[Mm][Dd]5-6)
                set_ssrr_method="rc4-md5-6"
                ;;
            6|[Cc][Hh][Aa][Cc][Hh][Aa]20)
                set_ssrr_method="chacha20"
                ;;
            7|[Cc][Hh][Aa][Cc][Hh][Aa]20-[Ii][Ee][Tt][Ff])
                set_ssrr_method="chacha20-ietf"
                ;;
            8|[Ss][Aa][Ll][As][Aa]20)
                set_ssrr_method="salsa20"
                ;;
            9|[Aa][Ee][Ss]-128-[Cc][Tt][Rr])
                set_ssrr_method="aes-128-ctr"
                ;;
            10|[Aa][Ee][Ss]-192-[Cc][Tt][Rr])
                set_ssrr_method="aes-192-ctr"
                ;;
            11|[Aa][Ee][Ss]-256-[Cc][Tt][Rr])
                set_ssrr_method="aes-256-ctr"
                ;;
            12|[Xx][Ss][Aa][Ll][As][Aa]20)
                set_ssrr_method="xsalsa20"
                ;;
            13|[Xx][Cc][Hh][Aa][Cc][Hh][Aa]20)
                set_ssrr_method="xchacha20"
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                set_ssrr_method="${def_ssrr_method}"
                ;;
        esac
        echo
        echo "---------------------------------------"
        echo "SSRR method: ${set_ssrr_method}"
        echo "---------------------------------------"
        echo
        def_ssrr_protocol="origin"
        echo -e "Please select Protocol plugin for ShadowsocksRR"
        echo "  1: origin (default)"
        echo "  2: auth_sha1_v4"
        echo "  3: auth_sha1_v4_compatible"
        echo "  4: auth_aes128_md5"
        echo "  5: auth_aes128_sha1"
        echo "  6: auth_chain_a"
        echo "  7: auth_chain_b"
        echo "  8: auth_chain_c"
        echo "  9: auth_chain_d"
        echo "  10: auth_chain_e"
        echo "  11: auth_chain_f"
        #read -p "Enter your choice (1, 2, 3, ... or exit. default [${def_ssrr_protocol}]): " set_ssrr_protocol
        case "${set_ssrr_protocol}" in
            1|[Oo][Rr][Ii][Gg][Ii][Nn])
                set_ssrr_protocol="origin"
                ;;
            2|[Aa][Uu][Tt][Hh]_[Ss][Hh][Aa]1_[Vv]4)
                set_ssrr_protocol="auth_sha1_v4"
                ;;
            3|[Aa][Uu][Tt][Hh]_[Ss][Hh][Aa]1_[Vv]4_[Cc][Oo][Mm][Pp][Aa][Tt][Ii][Bb][Ll][Ee])
                set_ssrr_protocol="auth_sha1_v4_compatible"
                ;;
            4|[Aa][Uu][Tt][Hh]_[Aa][Ee][Ss]128_[Mm][Dd]5)
                set_ssrr_protocol="auth_aes128_md5"
                ;;
            5|[Aa][Uu][Tt][Hh]_[Aa][Ee][Ss]128_[Ss][Hh][Aa]5)
                set_ssrr_protocol="auth_aes128_sha1"
                ;;
            6|[Aa][Uu][Tt][Hh]_[Cc][Hh][Aa][Ii][Nn]_[Aa])
                set_ssrr_protocol="auth_chain_a"
                ;;
            7|[Aa][Uu][Tt][Hh]_[Cc][Hh][Aa][Ii][Nn]_[Bb])
                set_ssrr_protocol="auth_chain_b"
                ;;
            8|[Aa][Uu][Tt][Hh]_[Cc][Hh][Aa][Ii][Nn]_[Cc])
                set_ssrr_protocol="auth_chain_c"
                ;;
            9|[Aa][Uu][Tt][Hh]_[Cc][Hh][Aa][Ii][Nn]_[Dd])
                set_ssrr_protocol="auth_chain_d"
                ;;
            10|[Aa][Uu][Tt][Hh]_[Cc][Hh][Aa][Ii][Nn]_[Ee])
                set_ssrr_protocol="auth_chain_e"
                ;;
            11|[Aa][Uu][Tt][Hh]_[Cc][Hh][Aa][Ii][Nn]_[Ff])
                set_ssrr_protocol="auth_chain_f"
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                set_ssrr_protocol="${def_ssrr_protocol}"
                ;;
        esac
        echo
        echo "---------------------------------------"
        echo "SSRR Protocol: ${set_ssrr_protocol}"
        echo "---------------------------------------"
        echo
        def_ssrr_obfs="plain"
        echo -e "Please select Obfs plugin for ShadowsocksRR"
        echo "  1: plain (default)"
        echo "  2: http_simple_compatible"
        echo "  3: http_simple"
        echo "  4: tls1.2_ticket_auth_compatible"
        echo "  5: tls1.2_ticket_auth"
        #read -p "Enter your choice (1, 2, 3, ... or exit. default [${def_ssrr_obfs}]): " set_ssrr_obfs
        case "${set_ssrr_obfs}" in
            1|[Pp][Ll][Aa][Ii][Nn])
                set_ssrr_obfs="plain"
                ;;
            2|[Hh][Tt][Tt][Pp]_[Ss][Ii][Mm][Pp][Ll][Ee]_[Cc][Oo][Mm][Pp][Aa][Tt][Ii][Bb][Ll][Ee])
                set_ssrr_obfs="http_simple_compatible"
                ;;
            3|[Hh][Tt][Tt][Pp]_[Ss][Ii][Mm][Pp][Ll][Ee])
                set_ssrr_obfs="http_simple"
                ;;
            4|[Tt][Ll][Ss]1.2_[Tt][Ii][Cc][Kk][Ee][Tt]_[Aa][Uu][Tt][Hh]_[Cc][Oo][Mm][Pp][Aa][Tt][Ii][Bb][Ll][Ee])
                set_ssrr_obfs="tls1.2_ticket_auth_compatible"
                ;;
            5|[Tt][Ll][Ss]1.2_[Tt][Ii][Cc][Kk][Ee][Tt]_[Aa][Uu][Tt][Hh])
                set_ssrr_obfs="tls1.2_ticket_auth"
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                set_ssrr_obfs="${def_ssrr_obfs}"
                ;;
        esac
        echo
        echo "---------------------------------------"
        echo "SSRR obfs: ${set_ssrr_obfs}"
        echo "---------------------------------------"
        echo
        echo "=========================================================="
    elif [ "${ssrr_installed_flag}" == "true" ]; then
        echo
        echo -e "${COLOR_PINK}ShadowsocksRR has been installed, nothing to do...${COLOR_END}"
        [ "${Install_Select}" == "6" ] && exit 0
    fi
    ###############################   KCPTUN   ###############################
    if [ "${kcptun_installed_flag}" == "false" ]; then
        echo
        echo "=========================================================="
        echo -e "${COLOR_PINK}Please input your KCPTUN setting:${COLOR_END}"
        echo
        def_kcptun_pwd=`randstr`
        echo "Please input password for KCPTUN"
        #read -p "(Default password: ${def_kcptun_pwd}):" set_kcptun_pwd
        [ -z "${set_kcptun_pwd}" ] && set_kcptun_pwd="${def_kcptun_pwd}"
        echo
        echo "---------------------------------------"
        echo "kcptun password = ${set_kcptun_pwd}"
        echo "---------------------------------------"
        echo
        # Set kcptun port
        while true
        do
            def_kcptun_port="38989"
            echo -e "Please input port for KCPTUN [1-65535]"
            #read -p "(Default port: ${def_kcptun_port}):" set_kcptun_port
            [ -z "$set_kcptun_port" ] && set_kcptun_port="${def_kcptun_port}"
            expr ${set_kcptun_port} + 0 &>/dev/null
            if [ $? -eq 0 ]; then
                if [ ${set_kcptun_port} -ge 1 ] && [ ${set_kcptun_port} -le 65535 ]; then
                    echo
                    echo "---------------------------------------"
                    echo "kcptun port = ${set_kcptun_port}"
                    echo "---------------------------------------"
                    echo
                    break
                else
                    echo "Input error, please input correct number"
                fi
            else
                echo "Input error, please input correct number"
            fi
        done
        if [ ! -z ${set_ss_libev_port} ]; then
            kcptun_target_port="${set_ss_libev_port}"
        elif [ ! -z ${set_ssr_port} ]; then
            kcptun_target_port="${set_ssr_port}"
        elif [ ! -z ${set_ssrr_port} ]; then
            kcptun_target_port="${set_ssrr_port}"
        else
            while true
            do
                def_kcptun_target_port=""
                #read -p "Please input kcptun Target Port for SS/SSR/SSRR/Socks5 [1-65535]:" set_kcptun_target_port
                [ -z "$set_kcptun_target_port" ] && set_kcptun_target_port="${def_kcptun_target_port}"
                expr ${set_kcptun_target_port} + 0 &>/dev/null
                if [ $? -eq 0 ]; then
                    if [ ${set_kcptun_target_port} -ge 1 ] && [ ${set_kcptun_target_port} -le 65535 ]; then
                        echo
                        echo "---------------------------------------"
                        echo "kcptun target port = ${set_kcptun_target_port}"
                        echo "---------------------------------------"
                        echo
                        break
                    else
                        echo "Input error, please input correct number"
                    fi
                else
                    echo "Input error, please input correct number"
                fi
            done
            kcptun_target_port="${set_kcptun_target_port}"
        fi
        def_kcptun_method="aes"
        echo -e "Please select method for KCPTUN"
        echo "  1: aes (default)"
        echo "  2: aes-128"
        echo "  3: aes-192"
        echo "  4: salsa20"
        echo "  5: blowfish"
        echo "  6: twofish"
        echo "  7: cast5"
        echo "  8: 3des"
        echo "  9: tea"
        echo " 10: xtea"
        echo " 11: xor"
        echo " 12: none"
        #read -p "Enter your choice (1, 2, 3, ... or exit. default [${def_kcptun_method}]): " set_kcptun_method
        case "${set_kcptun_method}" in
            1|[aA][eE][sS])
                set_kcptun_method="aes"
                ;;
            2|[aA][eE][sS]-128)
                set_kcptun_method="aes-128"
                ;;
            3|[aA][eE][sS]-192)
                set_kcptun_method="aes-192"
                ;;
            4|[sS][aA][lL][sS][aA]20)
                set_kcptun_method="salsa20"
                ;;
            5|[bB][lL][oO][wW][fF][iI][sS][hH])
                set_kcptun_method="blowfish"
                ;;
            6|[tT][wW][oO][fF][iI][sS][hH])
                set_kcptun_method="twofish"
                ;;
            7|[cC][aA][sS][tT]5)
                set_kcptun_method="cast5"
                ;;
            8|3[dD][eE][sS])
                set_kcptun_method="3des"
                ;;
            9|[tT][eE][aA])
                set_kcptun_method="tea"
                ;;
            10|[xX][tT][eE][aA])
                set_kcptun_method="xtea"
                ;;
            11|[xX][oO][rR])
                set_kcptun_method="xor"
                ;;
            12|[Nn][Oo][Nn][Ee])
                set_kcptun_method="none"
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                set_kcptun_method="${def_kcptun_method}"
                ;;
        esac
        echo
        echo "---------------------------------------"
        echo "kcptun method: ${set_kcptun_method}"
        echo "---------------------------------------"
        echo
        def_kcptun_mode="fast2"
        echo -e "Please select fast mode for KCPTUN"
        echo "1: fast"
        echo "2: fast2 (default)"
        echo "3: fast3"
        echo "4: normal"
        #read -p "Enter your choice (1, 2, 3, ... or exit. default [${def_kcptun_mode}]): " set_kcptun_mode
        case "${set_kcptun_mode}" in
            1|[fF][aA][sS][tT])
                set_kcptun_mode="fast"
                ;;
            2|[fF][aA][sS][tT]2)
                set_kcptun_mode="fast2"
                ;;
            3|[fF][aA][sS][tT]3)
                set_kcptun_mode="fast3"
                ;;
            4|[nN][oO][rR][mM][aA][lL])
                set_kcptun_mode="normal"
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                set_kcptun_mode="${def_kcptun_mode}"
                ;;
        esac
        echo
        echo "---------------------------------------"
        echo "kcptun mode: ${set_kcptun_mode}"
        echo "---------------------------------------"
        echo
        while true
        do
            def_kcptun_mtu="1350"
            echo -e "Please input MTU for KCPTUN [900-1400]"
            #read -p "(Default mtu: ${def_kcptun_mtu}):" set_kcptun_mtu
            [ -z "$set_kcptun_mtu" ] && set_kcptun_mtu="${def_kcptun_mtu}"
            expr ${set_kcptun_mtu} + 0 &>/dev/null
            if [ $? -eq 0 ]; then
                if [ ${set_kcptun_mtu} -ge 900 ] && [ ${set_kcptun_mtu} -le 1400 ]; then
                    echo
                    echo "---------------------------------------"
                    echo "kcptun mtu = ${set_kcptun_mtu}"
                    echo "---------------------------------------"
                    echo
                    break
                else
                    echo "Input error, please input correct number"
                fi
            else
                echo "Input error, please input correct number"
            fi
        done
        def_kcptun_compression="enable"
        echo -e "Please select Compression for KCPTUN"
        echo "1: enable (default)"
        echo "2: disable"
        #read -p "Enter your choice (1, 2 or exit. default [${def_kcptun_compression}]): " set_kcptun_compression
        case "${set_kcptun_compression}" in
            1|[yY]|[yY][eE][sS]|[tT][rR][uU][eE]|[eE][nN][aA][bB][lL][eE])
                set_kcptun_compression="enable"
                set_kcptun_nocomp="false"
                show_kcptun_nocomp=""
            ;;
            2|0|[nN]|[nN][oO]|[fF][aA][lL][sS][eE]|[dD][iI][sS][aA][bB][lL][eE])
                set_kcptun_compression="disable"
                set_kcptun_nocomp="true"
                show_kcptun_nocomp=" --nocomp"
            ;;
            *)
                set_kcptun_compression="enable"
                set_kcptun_nocomp="false"
                show_kcptun_nocomp=""
        esac
        echo
        echo "---------------------------------------"
        echo "kcptun compression: ${set_kcptun_compression}"
        echo "---------------------------------------"
        echo
        echo "=========================================================="
    elif [ "${kcptun_installed_flag}" == "true" ]; then
        echo
        echo -e "${COLOR_PINK}KCPTUN has been installed, nothing to do...${COLOR_END}"
        [ "${Install_Select}" == "3" ] && exit 0
        [ "${Install_Select}" == "4" ] && [ "${ss_libev_installed_flag}" == "true" ] && exit 0
        [ "${Install_Select}" == "5" ] && [ "${ssr_installed_flag}" == "true" ] && exit 0
        [ "${Install_Select}" == "7" ] && [ "${ssrr_installed_flag}" == "true" ] && exit 0
    fi
    get_latest_version
    down_ss_ssr_ssrr_kcptun
    config_ss_ssr_ssrr_kcptun
    install_ss_ssr_ssrr_kcptun
    install_cleanup
    if check_sys packageManager yum; then
        firewall_set
    fi
    show_ss_ssr_ssr_kcptun
}
uninstall_ss_ssr_ssrr_kcptun(){
    Get_Dist_Name
    clear
    def_Uninstall_Select="6"
    echo -e "${COLOR_YELOW}You have 5 options for your ss/ssr/ssrr/kcptun Uninstall${COLOR_END}"
    echo "1: Uninstall Shadowsocks-libev"
    echo "2: Uninstall ShadowsocksR(python)"
    echo "3: Uninstall KCPTUN"
    echo "4: Uninstall ShadowsocksRR(python)"
    echo "5: Uninstall All"
    echo "6: Exit,cancell uninstall [default]"
    read -p "Enter your choice (1, 2, 3, ... or exit. default [${def_Uninstall_Select}]): " Uninstall_Select
    case "${Uninstall_Select}" in
    1)
        echo
        echo -e "${COLOR_PINK}You will Uninstall Shadowsocks-libev${COLOR_END}"
        ;;
    2)
        echo
        echo -e "${COLOR_PINK}You will Uninstall ShadowsocksR(python)${COLOR_END}"
        ;;
    3)
        echo
        echo -e "${COLOR_PINK}You will Uninstall KCPTUN${COLOR_END}"
        ;;
    4)
        echo
        echo -e "${COLOR_PINK}You will Uninstall ShadowsocksRR(python)${COLOR_END}"
        ;;
    5)
        echo
        echo -e "${COLOR_PINK}You will Uninstall All${COLOR_END}"
        ;;
    6|[eE][xX][iI][tT])
        echo -e "${COLOR_PINK}You select <Exit>, shell exit now!${COLOR_END}"
        exit 1
        ;;
    *)
        echo
        echo -e "${COLOR_PINK}No input,default select <Exit>, shell exit now!${COLOR_END}"
        exit 1
    esac
    check_ss_ssr_ssrr_kcptun_installed
    if [ "${Uninstall_Select}" == "1" ] || [ "${Uninstall_Select}" == "5" ]; then
        if [ "${ss_libev_installed_flag}" == "true" ]; then
            ps -ef | grep -v grep | grep -i "ss-server" > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                /etc/init.d/shadowsocks stop
            fi
            if check_sys packageManager yum; then
                chkconfig --del shadowsocks
            elif check_sys packageManager apt; then
                update-rc.d -f shadowsocks remove
            fi
            rm -fr /etc/shadowsocks-libev
            rm -f /usr/local/bin/ss-local
            rm -f /usr/local/bin/ss-tunnel
            rm -f /usr/local/bin/ss-server
            rm -f /usr/local/bin/ss-manager
            rm -f /usr/local/bin/ss-redir
            rm -f /usr/local/bin/ss-nat
            rm -f /usr/local/lib/libshadowsocks-libev.a
            rm -f /usr/local/lib/libshadowsocks-libev.la
            rm -f /usr/local/include/shadowsocks.h
            rm -f /usr/local/lib/pkgconfig/shadowsocks-libev.pc
            rm -f /usr/local/share/man/man1/ss-local.1
            rm -f /usr/local/share/man/man1/ss-tunnel.1
            rm -f /usr/local/share/man/man1/ss-server.1
            rm -f /usr/local/share/man/man1/ss-manager.1
            rm -f /usr/local/share/man/man1/ss-redir.1
            rm -f /usr/local/share/man/man1/ss-nat.1
            rm -f /usr/local/share/man/man8/shadowsocks-libev.8
            rm -fr /usr/local/share/doc/shadowsocks-libev
            rm -f /usr/bin/shadowsocks
            rm -f /etc/init.d/shadowsocks
            echo -e "${COLOR_GREEN}Shadowsocks-libev uninstall success!${COLOR_END}"
        else
            echo -e "${COLOR_GREEN}Shadowsocks-libev not install!${COLOR_END}"
        fi
    fi
    if [ "${Uninstall_Select}" == "2" ] || [ "${Uninstall_Select}" == "5" ]; then
        if [ "${ssr_installed_flag}" == "true" ]; then
            /etc/init.d/ssr status > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                /etc/init.d/ssr stop
            fi
            if check_sys packageManager yum; then
                chkconfig --del ssr
            elif check_sys packageManager apt; then
                update-rc.d -f ssr remove
            fi
            rm -f ${ssr_config}
            rm -f /usr/bin/ssr
            rm -f /etc/init.d/ssr
            rm -f /var/log/shadowsocksR.log
            rm -rf /usr/local/shadowsocksR
            echo -e "${COLOR_GREEN}ShadowsocksR uninstall success!${COLOR_END}"
        else
            echo -e "${COLOR_GREEN}ShadowsocksR not install!${COLOR_END}"
        fi
    fi
    if [ "${Uninstall_Select}" == "3" ] || [ "${Uninstall_Select}" == "5" ]; then
        if [ "${kcptun_installed_flag}" == "true" ]; then
            /etc/init.d/kcptun status > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                /etc/init.d/kcptun stop
            fi
            if check_sys packageManager yum; then
                chkconfig --del kcptun
            elif check_sys packageManager apt; then
                update-rc.d -f kcptun remove
            fi
            rm -f ${kcptun_config}
            rm -f /usr/bin/kcptun
            rm -f /etc/init.d/kcptun
            rm -f /var/log/kcptun.log
            rm -rf /usr/local/kcptun
            echo -e "${COLOR_GREEN}KCPTUN uninstall success!${COLOR_END}"
        else
            echo -e "${COLOR_GREEN}KCPTUN not install!${COLOR_END}"
        fi
    fi
    if [ "${Uninstall_Select}" == "4" ] || [ "${Uninstall_Select}" == "5" ]; then
        if [ "${ssrr_installed_flag}" == "true" ]; then
            /etc/init.d/ssrr status > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                /etc/init.d/ssrr stop
            fi
            if check_sys packageManager yum; then
                chkconfig --del ssrr
            elif check_sys packageManager apt; then
                update-rc.d -f ssrr remove
            fi
            rm -f ${ssrr_config}
            rm -f /usr/bin/ssrr
            rm -f /etc/init.d/ssrr
            rm -f /var/log/shadowsocksRR.log
            rm -rf /usr/local/shadowsocksRR
            echo -e "${COLOR_GREEN}ShadowsocksRR uninstall success!${COLOR_END}"
        else
            echo -e "${COLOR_GREEN}ShadowsocksRR not install!${COLOR_END}"
        fi
    fi
}
configure_ss_ssr_ssrr_kcptun(){
    if [ -f ${ss_libev_config} ]; then
        echo -e "Shadowsocks-libev config file: ${COLOR_GREEN}${ss_libev_config}${COLOR_END}"
    fi
    if [ -f ${ssr_config} ]; then
        echo -e "ShadowsocksR config file:  ${COLOR_GREEN}${ssr_config}${COLOR_END}"
    fi
    if [ -f ${ssrr_config} ]; then
        echo -e "ShadowsocksRR config file:  ${COLOR_GREEN}${ssrr_config}${COLOR_END}"
    fi
    if [ -f ${kcptun_config} ]; then
        echo -e "KCPTUN config file: ${COLOR_GREEN}${kcptun_config}${COLOR_END}"
    fi
}
reconfig_ss_ssr_ssrr_kcptun(){
    cd ${cur_dir}
    reconfig_flag="false"
    echo -e "+ Reconfig ss_ssr_ssrr_kcp_bbr..."
    if [ -f ${ss_libev_config} ];then
        if [ -f shadowsocks-libev.json ];then
            if [ "${Install_obfs}" != "y" ] && [ ! "${Install_obfs}" != "Y" ]; then
                mv -f shadowsocks-libev.json ${ss_libev_config} && rm -rf shadowsocks-libev-obfs.json
                /etc/init.d/shadowsocks restart
	              reconfig_flag="true"
	          fi
	      fi  
        if [ -f shadowsocks-libev-obfs.json ];then
	          if [ "${Install_obfs}" == "y" ] || [ "${Install_obfs}" == "Y" ];then
	              mv -f shadowsocks-libev-obfs.json ${ss_libev_config} && rm -rf shadowsocks-libev.json
                /etc/init.d/shadowsocks restart
	              reconfig_flag="true"
	          fi
	      fi
    else 
        rm -f shadowsocks-libev.json shadowsocks-libev-obfs.json
    fi
    if [ -f ${ssr_config} ] && [ -f shadowsocksR.json ];then
        mv -f shadowsocksR.json ${ssr_config}
        /etc/init.d/ssr restart
        reconfig_flag="true"
    else 
        rm -f shadowsocksR.json shadowsocksR-Origin.json
    fi
    if [ -f ${ssrr_config} ] && [ -f shadowsocksRR.json ];then
        mv -f shadowsocksRR.json ${ssrr_config}
        /etc/init.d/ssrr restart
        reconfig_flag="true"
    else 
        rm -f shadowsocksRR.json shadowsocksRR-Origin.json
    fi
    if [ -f ${kcptun_config} ] &&  [ -f kcptun.json ] ;then
        mv -f kcptun.json ${kcptun_config}
        /etc/init.d/kcptun restart
        reconfig_flag="true"
    else 
        rm -f kcptun.json
    fi
    if [ -f firewall_set.sh ] && [ "${reconfig_flag}" == "true" ];then
        chmod +x ./firewall_set.sh
        ./firewall_set.sh
    fi
}
set_tool(){
    echo -e "+ Set tool.sh..."
    wget --no-check-certificate -O /root/tool.sh https://raw.githubusercontent.com/Jenking-Zhang/shell_for_ss_ssr_ssrr_kcptun_bbr/master/openvz_tool.sh
    chmod +x /root/tool.sh
}
update_ss_ssr_ssrr_kcptun(){
    ss_libev_update_flag="false"
    ssr_update_flag="false"
    kcptun_update_flag="false"
    clear
    echo -e "${COLOR_YELOW}You have 5 options for your kcptun/ss/ssr/ssrr update.${COLOR_END}"
    echo "1: Update Shadowsocks-libev"
    echo "2: Update ShadowsocksR(python)"
    echo "3: Update KCPTUN"
    echo "4: Update ShadowsocksRR(python)"
    echo "5: Update All"
    echo "6: Exit (default)"
    #read -p "Enter your choice (1, 2, 3, 4, 5 or exit. default [exit]): " Update_Select
    Update_Select=5

    case "${Update_Select}" in
    1)
        echo
        echo -e "${COLOR_PINK}You will update Shadowsocks-libev${COLOR_END}"
        ;;
    2)
        echo
        echo -e "${COLOR_PINK}You will update ShadowsocksR(python)${COLOR_END}"
        ;;
    3)
        echo
        echo -e "${COLOR_PINK}You will update KCPTUN${COLOR_END}"
        ;;
    4)
        echo
        echo -e "${COLOR_PINK}You will update ShadowsocksRR(python)${COLOR_END}"
        ;;
    5)
        echo
        echo -e "${COLOR_PINK}You will update All${COLOR_END}"
        ;;
    *)
        echo -e "${COLOR_PINK}You select <Exit>, shell exit now!${COLOR_END}"
        exit 1
        ;;
    esac
    check_ss_ssr_ssrr_kcptun_installed
    get_install_version
    get_latest_version
    if [[ "${Update_Select}" == "1" || "${Update_Select}" == "5" ]]; then
        echo "+-------------------------------------------------------------+"
        if [ "${ss_libev_installed_flag}" == "true" ]; then
            ss_libev_local_ver=$(ss-server --help | grep -i "shadowsocks-libev" | awk '{print $2}')
            if [ -z ${ss_libev_local_ver} ] || [ -z ${SS_LIBEV_VER} ]; then
                echo -e "${COLOR_RED}Error: Get Shadowsocks-libev shell version failed${COLOR_END}"
            else
                echo -e "Shadowsocks-libev shell version : ${COLOR_GREEN}${SS_LIBEV_VER}${COLOR_END}"
                echo -e "Shadowsocks-libev local version : ${COLOR_GREEN}${ss_libev_local_ver}${COLOR_END}"
                if [[ "${ss_libev_local_ver}" != "${SS_LIBEV_VER}" ]];then
                    ss_libev_update_flag="true"
                else
                    echo "Shadowsocks-libev local version is up-to-date."
                fi
            fi
        else
            echo -e "${COLOR_RED}Shadowsocks-libev not install!${COLOR_END}"
        fi
    fi
    if [[ "${Update_Select}" == "2" || "${Update_Select}" == "5" ]]; then
        echo "+-------------------------------------------------------------+"
        if [ "${ssr_installed_flag}" == "true" ]; then
            ssr_local_ver=$(ssr version | grep -i "shadowsocksr" | awk '{print $2}')
            if [ -z ${ssr_local_ver} ] || [ -z ${SSR_VER} ]; then
                echo -e "${COLOR_RED}Error: Get ShadowsocksR shell version failed${COLOR_END}"
            else
                echo -e "ShadowsocksR shell version : ${COLOR_GREEN}${SSR_VER}${COLOR_END}"
                echo -e "ShadowsocksR local version : ${COLOR_GREEN}${ssr_local_ver}${COLOR_END}"
                if [[ "${ssr_local_ver}" != "${SSR_VER}" ]];then
                    ssr_update_flag="true"
                else
                    echo "ShadowsocksR local version is up-to-date."
                fi
            fi
        else
            echo -e "${COLOR_RED}ShadowsocksR not install!${COLOR_END}"
        fi
    fi
    if [[ "${Update_Select}" == "3" || "${Update_Select}" == "5" ]]; then
        echo "+-------------------------------------------------------------+"
        if [ "${kcptun_installed_flag}" == "true" ]; then
            kcptun_local_ver=$(/usr/local/kcptun/kcptun --version | awk '{print $3}')
            if [ -z ${kcptun_local_ver} ] || [ -z ${KCPTUN_VER} ]; then
                echo -e "${COLOR_RED}Error: Get KCPTUN shell version failed${COLOR_END}"
            else
                echo -e "KCPTUN shell version : ${COLOR_GREEN}${KCPTUN_VER}${COLOR_END}"
                echo -e "KCPTUN local version : ${COLOR_GREEN}${kcptun_local_ver}${COLOR_END}"
                if [[ "${kcptun_local_ver}" != "${KCPTUN_VER}" ]];then
                    kcptun_update_flag="true"
                else
                    echo "KCPTUN local version is up-to-date."
                fi
            fi
        else
            echo -e "${COLOR_RED}KCPTUN not install!${COLOR_END}"
        fi
    fi
    if [[ "${Update_Select}" == "4" || "${Update_Select}" == "5" ]]; then
        echo "+-------------------------------------------------------------+"
        if [ "${ssrr_installed_flag}" == "true" ]; then
            ssrr_local_ver=$(ssrr version | grep -i "SSRR" | awk '{print $3}')
            if [ -z ${ssrr_local_ver} ] || [ -z ${SSRR_VER} ]; then
                echo -e "${COLOR_RED}Error: Get ShadowsocksRR shell version failed${COLOR_END}"
            else
                echo -e "ShadowsocksRR shell version : ${COLOR_GREEN}${SSRR_VER}${COLOR_END}"
                echo -e "ShadowsocksRR local version : ${COLOR_GREEN}${ssrr_local_ver}${COLOR_END}"
                if [[ "${ssrr_local_ver}" != "${SSRR_VER}" ]];then
                    ssrr_update_flag="true"
                else
                    echo "ShadowsocksRR local version is up-to-date."
                fi
            fi
        else
            echo -e "${COLOR_RED}ShadowsocksRR not install!${COLOR_END}"
        fi
    fi
    if [[ "${ss_libev_update_flag}" == "true" || "${ssr_update_flag}" == "true" || "${ssrr_update_flag}" == "true" || "${kcptun_update_flag}" == "true" ]]; then
        echo "+-------------------------------------------------------------+"
        echo -e "${COLOR_GREEN}Found a new version,update now...${COLOR_END}"
        Press_Start
    fi
    if [[ "${ss_libev_installed_flag}" == "true" && "${ss_libev_update_flag}" == "true" ]]; then
        ps -ef | grep -v grep | grep -i "ss-server" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            /etc/init.d/shadowsocks stop
        fi
        if check_sys packageManager yum; then
            chkconfig --del shadowsocks
        elif check_sys packageManager apt; then
            update-rc.d -f shadowsocks remove
        fi
        rm -f /usr/local/bin/ss-local
        rm -f /usr/local/bin/ss-tunnel
        rm -f /usr/local/bin/ss-server
        rm -f /usr/local/bin/ss-manager
        rm -f /usr/local/bin/ss-redir
        rm -f /usr/local/bin/ss-nat
        rm -f /usr/local/lib/libshadowsocks-libev.a
        rm -f /usr/local/lib/libshadowsocks-libev.la
        rm -f /usr/local/include/shadowsocks.h
        rm -f /usr/local/lib/pkgconfig/shadowsocks-libev.pc
        rm -f /usr/local/share/man/man1/ss-local.1
        rm -f /usr/local/share/man/man1/ss-tunnel.1
        rm -f /usr/local/share/man/man1/ss-server.1
        rm -f /usr/local/share/man/man1/ss-manager.1
        rm -f /usr/local/share/man/man1/ss-redir.1
        rm -f /usr/local/share/man/man1/ss-nat.1
        rm -f /usr/local/share/man/man8/shadowsocks-libev.8
        rm -fr /usr/local/share/doc/shadowsocks-libev
        rm -f /usr/bin/shadowsocks
        rm -f /etc/init.d/shadowsocks
    fi
    if [[ "${ssr_installed_flag}" == "true" && "${ssr_update_flag}" == "true" ]]; then
        /etc/init.d/ssr status > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            /etc/init.d/ssr stop
        fi
        if check_sys packageManager yum; then
            chkconfig --del ssr
        elif check_sys packageManager apt; then
            update-rc.d -f ssr remove
        fi
        rm -f /usr/bin/ssr
        rm -f /etc/init.d/ssr
        rm -f /var/log/shadowsocksR.log
        rm -rf /usr/local/shadowsocksR/shadowsocks
    fi
    if [[ "${ssrr_installed_flag}" == "true" && "${ssrr_update_flag}" == "true" ]]; then
        /etc/init.d/ssrr status > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            /etc/init.d/ssrr stop
        fi
        if check_sys packageManager yum; then
            chkconfig --del ssrr
        elif check_sys packageManager apt; then
            update-rc.d -f ssrr remove
        fi
        rm -f /usr/bin/ssrr
        rm -f /etc/init.d/ssrr
        rm -f /var/log/shadowsocksRR.log
        rm -rf /usr/local/shadowsocksRR
    fi
    if [[ "${kcptun_installed_flag}" == "true" && "${kcptun_update_flag}" == "true" ]]; then
        /etc/init.d/kcptun status > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            /etc/init.d/kcptun stop
        fi
        if check_sys packageManager yum; then
            chkconfig --del kcptun
        elif check_sys packageManager apt; then
            update-rc.d -f kcptun remove
        fi
        rm -f /usr/bin/kcptun
        rm -f /etc/init.d/kcptun
        rm -f /var/log/kcptun.log
        rm -f /usr/local/kcptun/kcptun
    fi
    if [[ "${ss_libev_update_flag}" == "true" || "${ssr_update_flag}" == "true" || "${ssrr_update_flag}" == "true" || "${kcptun_update_flag}" == "true" ]]; then
        down_ss_ssr_ssrr_kcptun
        install_ss_ssr_ssrr_kcptun
        install_cleanup
    else
        echo
        echo -e "nothing to do..."
        echo
        exit 1
    fi
    if [[ "${kcptun_install_flag}" == "true" || "${ss_libev_install_flag}" == "true" || "${ssr_install_flag}" == "true" || "${ssrr_install_flag}" == "true" ]]; then
        echo "Congratulations, update completed, Enjoy it!"
        echo
    else
        echo
        echo -e "${COLOR_RED}Update failed!${COLOR_END}"
        exit 1
    fi
}
set_text_color
shell_update
# Initialization
shell_action=$1
clear
cur_dir=$(pwd)
Get_Dist_Name
Check_OS_support
[  -z ${shell_action} ] && shell_action="install"
case "${shell_action}" in
[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii])
    #pre_install_ss_ssr_ssrr_kcptun 2>&1 | tee ${cur_dir}/ss-ssr-kcptun-install.log
    pre_install_ss_ssr_ssrr_kcptun
    reconfig_ss_ssr_ssrr_kcptun
    set_tool
    install_bbr
    set_crontab
    install_cleanup
    if [ -f /root/install.sh ]; then rm -f /root/install.sh; fi
    if [ -f /root/firewall_set.sh ]; then rm -f /root/firewall_set.sh; fi
    ;;
[Cc]|[Cc][Oo][Nn][Ff][Ii][Gg]|-[Cc]|--[Cc])
    configure_ss_ssr_ssrr_kcptun
    ;;
[Uu][Nn]|[Uu][Nn][Ii][Nn][Ss][Tt][Aa][Ll][Ll]|[Uu][Nn]|-[Uu][Nn]|--[Uu][Nn])
    #uninstall_ss_ssr_ssrr_kcptun 2>&1 | tee ${cur_dir}/ss-ssr-kcptun-uninstall.log
    uninstall_ss_ssr_ssrr_kcptun
    ;;
[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp])
    #update_ss_ssr_ssrr_kcptun 2>&1 | tee ${cur_dir}/ss-ssr-kcptun-update.log
    update_ss_ssr_ssrr_kcptun
    ;;
*)
    clear
    echo "Arguments error! [${shell_action}]"
    echo "Usage: `basename $0` {install|uninstall|update|config}"
    ;;
esac
