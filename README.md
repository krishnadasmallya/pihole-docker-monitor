# pihole-docker-monitor

An dockerized pihole and monitors all together for easier installation and maintenance

Using default images and quick configuration for [Pihole](https://github.com/pi-hole/docker-pi-hole/#running-pi-hole-docker), [node exporter](https://prometheus.io/docs/guides/node-exporter/), [Speeedtest Prometheus exporter](https://github.com/jeanralphaviles/prometheus_speedtest), grafana dashboards - [1860](https://grafana.com/grafana/dashboards/1860), [10176](https://grafana.com/grafana/dashboards/10176) and an customized as a single page version of [11229](https://grafana.com/grafana/dashboards/11229)

### Prerequisite
  * Docker &  Docker-Compose

### Installation
  * Download the latest release zip
  * Unzip the contents and change directory to "pihole"
  * execute "./install.sh" from the directory on your pi
