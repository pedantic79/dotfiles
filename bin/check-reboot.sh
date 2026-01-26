#!/bin/bash

if [ -f /var/run/reboot-required ]; then
    echo "Reboot required on $(hostname) due to unattended-upgrades." | mail -s "Reboot Required: $(hostname)" "${EMAIL:-$USER}"
fi
