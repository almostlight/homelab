if status is-interactive
    set -U fish_greeting
    clear
    uptime
    if test -e /sys/class/power_supply/BAT0/capacity
        cat /var/log/batcheck.log
    end
    pwrstat -status | grep State
    pct list
end

# alias reboot='echo "unavailable on this system"'
alias kexec-reboot='\
	echo "kernel: $(uname -r)" \
	&& kexec -l /boot/vmlinuz-$(uname -r) --initrd=/boot/initrd.img-$(uname -r) --reuse-cmdline \
	&& systemctl kexec'
alias lxc="pct"
alias enter="pct enter"
alias daemon-reload="systemctl daemon-reload"
