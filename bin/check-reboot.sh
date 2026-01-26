#!/bin/bash

U="${EMAIL:-$USER}"
reboot_sent="/tmp/.${U}-check-reboot/sent"

if [ -f /var/run/reboot-required ]; then
    if [ ! -f "$reboot_sent" ]; then
        echo "Reboot required on $(hostname) due to unattended-upgrades." | mail -s "Reboot Required: $(hostname)" "$U"
        mkdir -p $(dirname "$reboot_sent")
        touch "$reboot_sent"
    fi
fi
