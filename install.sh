#!/bin/bash
set -e -x

sudo apt update && sudo apt upgrade
sudo apt install docker docker-compose  # portainer

cd /opt
sudo mkdir -p {prometheus,pihole/{pihole,dnsmasq.d},grafana/provisioning/{datasources,dashboards},tmpinst}
IPAddr=`hostname -I | cut -d' ' -f1`
#Download and modify configuration files
sudo curl -s https://raw.githubusercontent.com/halod2003/pihole/main/prometheus.yml -o prometheus/prometheus.yml
sudo curl -s https://raw.githubusercontent.com/halod2003/pihole/main/docker-compose.yml -o tmpinst/docker-compose.yml
sudo curl -s https://raw.githubusercontent.com/halod2003/pihole/main/datasource.yml -o grafana/provisioning/datasources/datasource.yml
sudo curl -sL https://raw.githubusercontent.com/halod2003/pihole/main/dashboard.yml  -o grafana/provisioning/dashboards/dashboard.yml
sudo curl -sL https://grafana.com/api/dashboards/1860/revisions/23/download -o grafana/provisioning/dashboards/dash1.json
sudo curl -sL https://grafana.com/api/dashboards/10176/revisions/2/download -o grafana/provisioning/dashboards/dash2.json
sudo sed -i "s/IP_Addr/$IPAddr/" prometheus/prometheus.yml
sudo sed -i "s/IP_Addr/$IPAddr/" tmpinst/docker-compose.yml
sudo sed -i "s/IP_Addr/$IPAddr/" grafana/provisioning/datasources/datasource.yml

## 4) Install Node Exporter

sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-armv7.tar.gz
sudo tar xfz node_exporter-1.1.2.linux-armv7.tar.gz
sudo rm node_exporter-1.1.2.linux-armv7.tar.gz
sudo mv node_exporter-1.1.2.linux-armv7/ node_exporter
sudo curl -s https://raw.githubusercontent.com/halod2003/pihole/main/node_exporter.service -o /etc/systemd/system/node_exporter.service
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

## 5) Install services using docker-compose

sudo docker-compose -f tmpinst/docker-compose.yml up -d

#clean-up
sudo rm -r tmpinst

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
