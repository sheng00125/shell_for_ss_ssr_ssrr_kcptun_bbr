#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

cur_dir=$(pwd)
remote_bbr_version=$(wget --no-check-certificate -qO- https://api.github.com/repos/linhua55/lkl_study/releases/latest | grep 'tag_name' | cut -d\" -f4 | sed s/v//g )
RINET_BBR_URL="https://github.com/linhua55/lkl_study/releases/download/v${remote_bbr_version}/rinetd_bbr_powered"
BBR_INIT_URL="https://raw.githubusercontent.com/Jenking-Zhang/shell/master/ss_ssr_kcp_bbr_netspeeder/bbr.init"

COLOR_RED='\E[1;31m'
COLOR_GREEN='\E[1;32m'
COLOR_YELOW='\E[1;33m'
COLOR_BLUE='\E[1;34m'
COLOR_PINK='\E[1;35m'
COLOR_PINKBACK_WHITEFONT='\033[45;37m'
COLOR_GREEN_LIGHTNING='\033[32m \033[05m'
COLOR_END='\E[0m'

if [ "$(id -u)" != "0" ]; then
    echo -e "${COLOR_RED}ERROR: You must be root to run this script!${COLOR_END}"
    exit 1
fi

#for CMD in wget iptables grep cut ip awk
#do
#	if ! type -p ${CMD}; then
#		echo -e "\e[1;31mtool ${CMD} is not installed, abort.\e[0m"
#		packge=${packge}${CMD}
#		yum install $packge -y
#	fi
#done

echo -e "Get the Rinetd-BBR version:${COLOR_GREEN}${remote_bbr_version}${COLOR_END}"
echo " Download Rinetd-BBR from $RINET_BBR_URL"
curl -L "${RINET_BBR_URL}" >/usr/bin/rinetd-bbr
chmod +x /usr/bin/rinetd-bbr

echo "Config Rinetd-BBR..."
[ ! -d /etc/rinetd-bbr/ ] && mkdir /etc/rinetd-bbr/
[ -d /etc/rinetd-bbr/bbr.conf ] && rm -rf /etc/rinetd-bbr/bbr.conf
cat <<EOF > /etc/rinetd-bbr/bbr.conf
#bbr_version="${remote_bbr_version}"
# bindadress bindport connectaddress connectport
0.0.0.0 443 0.0.0.0 443
EOF

echo "Config service..."
wget --no-check-certificate "${BBR_INIT_URL}" -O /etc/init.d/bbr
chmod +x /etc/init.d/bbr
chkconfig --add bbr
chkconfig bbr on

/etc/init.d/bbr start

exit 0
