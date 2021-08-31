#!/bin/bash
set -e -x

workdir=/tmp/work/pihole_monitor

mkdir -p $workdir/

sudo cp -r grafana /opt/
sudo cp -r prometheus /opt/
sudo cp -r node_exporter.service $workdir/
sudo cp -r docker-compose.yml $workdir/

cd /opt
sudo mkdir -p {pihole/{pihole,dnsmasq.d}}
IPAddr=`hostname -I | cut -d' ' -f1`
#Download and modify configuration files
sudo curl -sL https://grafana.com/api/dashboards/1860/revisions/23/download -o grafana/provisioning/dashboards/dash1.json
sudo curl -sL https://grafana.com/api/dashboards/10176/revisions/2/download -o grafana/provisioning/dashboards/dash2.json
sudo sed -i "s/IP_Addr/$IPAddr/" prometheus/prometheus.yml
sudo sed -i "s/IP_Addr/$IPAddr/" $workdir/docker-compose.yml
sudo sed -i "s/IP_Addr/$IPAddr/" grafana/provisioning/datasources/datasource.yml

## 4) Install Node Exporter

sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-armv7.tar.gz
sudo tar xfz node_exporter-1.1.2.linux-armv7.tar.gz
sudo rm node_exporter-1.1.2.linux-armv7.tar.gz
sudo mv node_exporter-1.1.2.linux-armv7 node_exporter
sudo mv $workdir/node_exporter.service /etc/systemd/system/node_exporter.service
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

## 5) Install services using docker-compose

sudo docker-compose -f $workdir/docker-compose.yml up -d

## 6) Print access information

echo Installation complete
echo "    "
echo "Access Information"
echo "------------------"
echo "    "
echo "Pi-hole http://$IPAddr"
echo "Grafana http://$IPAddr:3000"
echo "Portainer http://$IPAddr:9000"
echo "Prometheus http://$IPAddr:9090"
echo "Press any key to continue"
while [ true ] ; do
read -t 15 -n 1
if [ $? = 0 ] ; then
exit ;
else
echo "waiting for the keypress"
fi
done