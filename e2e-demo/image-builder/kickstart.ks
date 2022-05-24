lang en_US.UTF-8
keyboard us
timezone UTC
zerombr
clearpart --all --initlabel
autopart --type=plain --fstype=xfs --nohome
reboot
text
network --bootproto=dhcp --device=link --activate --onboot=on

ostreesetup --osname=rhel-edge-microshift --remote=rhel-edge-microshift --url=file:///run/install/repo/ostree/repo --ref=rhel/8/x86_64/edge --nogpg

%post --log=/var/log/anaconda/post-install.log --erroronfail
useradd -m -d /home/redhat -p \$5\$XDVQ6DxT8S5YWLV7\$8f2om5JfjK56v9ofUkUAwZXTxJl3Sqnc9yPnza4xoJ0 -G wheel redhat
mkdir -p /home/redhat/.ssh
chmod 755 /home/redhat/.ssh
tee /home/redhat/.ssh/authorized_keys > /dev/null << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCq1zY7mXMLJdQ2cM8KaGxMq7ZzCsJLlh0YtBKnOR6Iot6QojGanizfNlLHFkzuGUCgp4h2Dhm9MIz6Lfqn658nhBvv4hSOb4i2SkU1wT49kqa0bmx0klZeUcqwoVoDm4yD9iiWl+oUm8nrs80i0r3NDtnHNPvKmPtWLJQzlsPEzW/fEncSHTHkypdZh06uCzNn8WCfOqnCaS9ZkXHdl7tC4DzVQYFt486YZVdEzc1cMbFHCSTRvo6kboTns+rrw4uFBhJeqvud+51qqf0l3HCimUyfMp85aH51yOXVZ2Qx3mhODhrkWl82d5XOnJ3TdEBSmdqtkrCOfVXQE2gX3kGGPX6PJFMq6XqLksIbm3EhFtnxPQST1tydWZfeGM41NeCXe/GUjeL2OqyBtuvwRwHDQMx6Qaz/DayXn/mhN7YfQV25jHPE0SkS0xT7PyyPuYSPCPtHg224D6DsjvsOBimL/HSXRES1r+UwHoPHd8CUfql+O1/1mG8xFGQ3NKLe/F0= gbsalinetti@feynman
EOF
echo -e 'redhat\tALL=(ALL)\tNOPASSWD: ALL' >> /etc/sudoers

echo -e 'https://github.com/giannisalinetti/microshift-config?ref=${insightsid}' > /etc/transmission-url
%end

%post --log=/var/log/anaconda/insights-on-reboot-unit-install.log --interpreter=/usr/bin/bash --erroronfail
INSIGHTS_CLIENT_OVERRIDE_DIR=/etc/systemd/system/insights-client.service.d
INSIGHTS_CLIENT_OVERRIDE_FILE=$INSIGHTS_CLIENT_OVERRIDE_DIR/override.conf
INSIGHTS_MACHINE_ID_FILE=/etc/insights-client/machine-id

if [ ! -f $INSIGHTS_CLIENT_OVERRIDE_FILE ]; then
    mkdir -p $INSIGHTS_CLIENT_OVERRIDE_DIR
    cat > $INSIGHTS_CLIENT_OVERRIDE_FILE << EOF 
[Unit]
Requisite=greenboot-healthcheck.service
After=network-online.target greenboot-healthcheck.service

[Install]
WantedBy=multi-user.target
EOF
    systemctl enable insights-client.service
fi

if [ ! -f $INSIGHTS_MACHINE_ID_FILE ]; then
    uuidgen -r > $INSIGHTS_MACHINE_ID_FILE
fi
%end

