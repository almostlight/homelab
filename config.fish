if status is-interactive
    set -U fish_greeting
    if acpi 2>/dev/null | grep -oE [0-9]+% | sed s/%//
        cat /var/log/batcheck.log
    end
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
