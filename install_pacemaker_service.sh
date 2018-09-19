#!/bin/bash
echo "Installing pacemaker autorun service to systemd"

sudo -u root cat > /lib/systemd/system/pacemaker.service <<EOL
[Unit]
Description=Arbitron pacemaker service

[Service]
WorkingDirectory=/home/mike/Arbitron
ExecStart=/home/mike/Arbitron/bin/python3 /home/mike/Arbitron/pacemaker.py

[Install]
WantedBy=multi-user.target
EOL
sudo chmod 644 /lib/systemd/system/pacemaker.service
sudo systemctl daemon-reload
sudo systemctl enable pacemaker.service
echo sudo systemctl start pacemaker.service
