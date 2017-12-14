#!/bin/bash
# Usage:
#   curl https://raw.githubusercontent.com/linhua55/lkl_study/master/get-rinetd.sh | bash

export RINET_URL="https://github.com/linhua55/lkl_study/releases/download/v1.2/rinetd_bbr_powered"
export BBR_INIT_URL="https://raw.githubusercontent.com/Jenking-Zhang/shell_for_ss_ssr_ssrr_kcptun_bbr/master/bbr.init"



if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Please run as root"
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

echo "1. Download rinetd-bbr from $RINET_URL"
curl -L "${RINET_URL}" >/usr/bin/rinetd-bbr
chmod +x /usr/bin/rinetd-bbr

echo "2. Generate /etc/rinetd-bbr/bbr.conf"
mkdir /etc/rinetd-bbr/
cat <<EOF > /etc/rinetd-bbr/bbr.conf
# bindadress bindport connectaddress connectport
0.0.0.0 443 0.0.0.0 443
EOF

echo "3. Config service"
wget --no-check-certificate "${BBR_INIT_URL}" -O /etc/init.d/bbr
chmod +x /etc/init.d/bbr
chkconfig --add bbr
chkconfig bbr on

/etc/init.d/bbr start

exit 0
