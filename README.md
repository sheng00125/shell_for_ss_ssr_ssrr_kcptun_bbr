# shell_for_ss_ssr_ssrr_kcptun_bbr_installation
参数设置已屏蔽，如需指定参数，取消参数设置部分“read”部分注释即可！
<a name="Install_command">安装命令：
```Bash
wget --no-check-certificate -O /root/ss_ssr_ssrr_kcp_bbr.sh https://github.com/sheng00125/shell_for_ss_ssr_ssrr_kcptun_bbr/blob/master/ss_ssr_ssrr_kcp_bbr.sh
chmod +x /root/ss_ssr_ssrr_kcp_bbr.sh
/root/ss_ssr_ssrr_kcp_bbr.sh install 2>&1 | tee install.log
```
OPENVZ开启了TAP/TUN会提示安装BBR！

<a name="Install_command">非OPENVZ安装BBR：
```Bash
wget -O /root/bbr_kvm.sh --no-check-certificate https://raw.githubusercontent.com/Jenking-Zhang/shell_for_ss_ssr_ssrr_kcptun_bbr/master/bbr_kvm.sh
chmod +x /root/bbr_kvm.sh
/root/bbr_kvm.sh 2>&1 | tee bbr_install.log
```
需执行两次，自动重启，第一次安装内核，第二次安装BBR暴力版。非OPENVZ架构的VPS，建议先更换内核，安装BBR后，再安装SS/SSR/SSRR！
