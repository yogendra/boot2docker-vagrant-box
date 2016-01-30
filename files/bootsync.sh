#!/bin/sh

# Place oem-release in /etc
ln -s /var/lib/boot2docker/oem-release /etc/oem-release

# Point docker home dir to /mnt/sda1
rm -rf /home/docker

ln -s /mnt/sda1/docker /home/docker

# if docker .ssh does not exists then create it
if [ ! -e /home/docker/.ssh ]
then
	mkdir -p /home/docker/.ssh

	cat >/home/docker/.ssh/authorized_keys <<KEY
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
KEY

	chmod 0700 /home/docker/.ssh
	chmod 0600 /home/docker/.ssh/authorized_keys
	chown -R docker:staff /home/docker/.ssh
fi


# Start NFS client for NFS synced folder
if [ -x /usr/local/etc/init.d/nfs-client ]; then
  /usr/local/etc/init.d/nfs-client start
fi

# Place docker in /usr/bin for guest capability check
ln -s /usr/local/bin/docker /usr/bin/docker

