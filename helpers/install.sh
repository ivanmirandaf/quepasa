#!/bin/bash
echo 'Installation tested on fresh Ubuntu (20.04|22.04) (ARM64|AMD64)'

echo 'Installing GCC'
apt install gcc -y

echo 'Installing GO language'

# for rpm versions rpm --eval '%{_arch}'
ARCH=`dpkg --print-architecture`

echo "Installing for arch ${ARCH}"
wget https://go.dev/dl/go1.20.3.linux-${ARCH}.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.20.3.linux-${ARCH}.tar.gz
GOPATH=/usr/local/go
PATH=$PATH:$GOPATH/bin
ln -sf ${GOPATH}/bin/go /usr/sbin/go
sed -nir '/^export GOPATH=/!p;$a export GOPATH='${GOPATH} ~/.bashrc
sed -nir '/^export PATH=/!p;$a export PATH='$PATH:$GOPATH/bin ~/.bashrc
go version

echo 'Updating Quepasa link'
ln -sf /opt/quepasa-source/src /opt/quepasa 

echo 'Updating logging'
ln -sf /opt/quepasa-source/helpers/syslog.conf /etc/rsyslog.d/10-quepasa.conf

echo 'Updating log rotate'
ln -sf /opt/quepasa-source/helpers/quepasa.logrotate.d /etc/logrotate.d/quepasa

/bin/mkdir -p /var/log/quepasa
/bin/chmod 755 /var/log/quepasa
/bin/chown syslog:adm /var/log/quepasa

echo 'Restarting services'
systemctl restart rsyslog

echo 'Updating systemd service'
ln -sf /opt/quepasa-source/helpers/quepasa.service /etc/systemd/system/quepasa.service
systemctl daemon-reload

adduser --disabled-password --gecos "" --home /opt/quepasa quepasa
chown -R quepasa /opt/quepasa-source

cp /opt/quepasa-source/helpers/.env /opt/quepasa/.env

systemctl enable quepasa.service
systemctl start quepasa

# Hint: Setup Quepasa user
echo 'Setup Quepasa user >>>  http://<your-ip>:31000/setup'

exit 0
