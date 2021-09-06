#!/bin/bash
set -e -x

while true; do
  read -s -p "Admin Password: " password
  echo
  read -s -p "Confirm Admin Password: " password2
  echo
  [ "$password" = "$password2" ] && break
  echo "Please try again"
done

workdir=/tmp/work/pihole_monitor
installdir=/opt/pihole_monitor
REPLACE_IPADDR=`hostname -I | cut -d' ' -f1`

mkdir -p $workdir/
sudo mkdir -p $installdir/

sudo cp -r grafana $installdir/
sudo cp -r prometheus $installdir/
sudo cp -r pihole $installdir/
sudo cp -r node_exporter.service $workdir/
sudo cp -r docker-compose.yml $workdir/

cd $installdir/
sudo mkdir -p pihole/{pihole,dnsmasq.d}
#Download and modify configuration files
sudo curl -sL https://grafana.com/api/dashboards/1860/revisions/23/download -o grafana/provisioning/dashboards/node-exporter-full.json
sudo curl -sL https://grafana.com/api/dashboards/10176/revisions/2/download -o grafana/provisioning/dashboards/pi-hole-exporter.json
sudo sed -i "s/REPLACE_IPADDR/$REPLACE_IPADDR/" prometheus/prometheus.yml
sudo sed -i "s/REPLACE_IPADDR/$REPLACE_IPADDR/" $workdir/docker-compose.yml
sudo sed -i "s/REPLACE_IPADDR/$REPLACE_IPADDR/" grafana/provisioning/datasources/datasource.yml

sudo sed -i "s/REPLACE_PASSWD/$password/" $workdir/docker-compose.yml
sudo sed -i "s|REPLACE_INSTALLDIR|$installdir|" $workdir/docker-compose.yml

## 4) Install Node Exporter
Admin!234
sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-armv7.tar.gz
sudo tar xfz node_exporter-1.1.2.linux-armv7.tar.gz
sudo rm node_exporter-1.1.2.linux-armv7.tar.gz
sudo mv node_exporter-1.1.2.linux-armv7 node_exporter
sudo sed -i "s/REPLACE_USER/$USER/" $workdir/node_exporter.service
sudo sed -i "s|REPLACE_INSTALLDIR|$installdir|" $workdir/node_exporter.service
sudo mv $workdir/node_exporter.service /etc/systemd/system/node_exporter.service

if sudo systemctl --all --type service | grep -q "node_exporter"; then
  sudo systemctl daemon-reload
  sudo systemctl restart node_exporter
else
  sudo systemctl start node_exporter
  sudo systemctl enable node_exporter
fi

## 5) Install services using docker-compose

sudo docker-compose -f $workdir/docker-compose.yml up -d

sleep 10

## Pull adblocklist and update gravity
sudo docker exec PiHole /etc/pihole/add-ticked-list.sh
## 6) Print access information

echo Installation complete
echo "Access Information"
echo "------------------"
echo "Pi-hole http://$REPLACE_IPADDR/admin"
echo "Grafana http://$REPLACE_IPADDR:3000"
echo "Portainer http://$REPLACE_IPADDR:9000"
echo "Prometheus http://$REPLACE_IPADDR:9090"
echo "Press any key to continue"
while [ true ] ; do
read -t 15 -n 1
if [ $? = 0 ] ; then
exit ;
else
echo "waiting for the keypress"
fi
done