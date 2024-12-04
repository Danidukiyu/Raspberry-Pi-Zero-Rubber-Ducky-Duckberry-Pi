#!/bin/bash

# Ensure script is run as root
if [ $EUID -ne 0 ]; then
    echo "You must use sudo to run this script:"
    echo "sudo $0 $@"
    exit 1
fi

# Update system and install necessary tools
apt-get update
apt-get upgrade -y
apt-get install -y rpi-update git wget build-essential

# Install necessary dependencies
apt-get install -y libusb-1.0-0-dev

# Update firmware (be cautious with rpi-update)
BRANCH=stable rpi-update

# Enable USB OTG (dwc2) support in /boot/config.txt
echo "dtoverlay=dwc2" >> /boot/config.txt

# Create directory for USB gadget configuration
mkdir -p /etc/systemd/system/duckpi.service

# Download necessary scripts and files
cd /home/pi
wget --no-check-certificate https://raw.githubusercontent.com/ossiozac/Raspberry-Pi-Zero-Rubber-Ducky-Duckberry-Pi/master/LICENSE
wget --no-check-certificate https://raw.githubusercontent.com/ossiozac/Raspberry-Pi-Zero-Rubber-Ducky-Duckberry-Pi/master/duckpi.sh
wget --no-check-certificate https://github.com/ossiozac/Raspberry-Pi-Zero-Rubber-Ducky-Duckberry-Pi/raw/master/usleep
wget --no-check-certificate https://github.com/ossiozac/Raspberry-Pi-Zero-Rubber-Ducky-Duckberry-Pi/raw/master/usleep.c
wget --no-check-certificate https://github.com/ossiozac/Raspberry-Pi-Zero-Rubber-Ducky-Duckberry-Pi/raw/master/hid-gadget-test

# Make downloaded files executable
chmod +x /home/pi/duckpi.sh /home/pi/usleep /home/pi/hid-gadget-test

# Install USB gadget modules and enable them on boot
echo "dwc2" >> /etc/modules
echo "g_hid" >> /etc/modules

# Create systemd service to launch the payload
cat <<EOF > /etc/systemd/system/duckpi.service
[Unit]
Description=USB HID Payload Service
After=multi-user.target

[Service]
ExecStart=/home/pi/duckpi.sh /home/pi/payload.dd
WorkingDirectory=/home/pi
Type=simple

[Install]
WantedBy=multi-user.target
EOF

# Enable the systemd service to start on boot
systemctl enable duckpi.service

# Create a default payload to simulate keystrokes (e.g., open a website)
cat <<EOF > /boot/payload.dd
GUI r
DELAY 50
STRING www.youtube.com/watch?v=dQw4w9WgXcQ
ENTER
EOF

# Final output
echo "Setup complete. Reboot your Raspberry Pi to apply changes."
echo "You can change the payload in /boot/payload.dd to simulate different keystrokes."

