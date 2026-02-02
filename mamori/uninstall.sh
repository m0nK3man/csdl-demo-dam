#!/bin/bash

sudo docker kill mamori
sudo docker kill mamori-wireguard

sudo docker rm mamori mamori-wireguard
sudo docker rmi iomamori/mamori-all-in-one mamori-wireguard mamori-alpine-boringtun
sudo docker volume rm \
        mamori-var \
        mamori-nginx-conf \
        mamori-data \
        mamori-pg-conf \
        mamori-influxdb \
        mamori-influxdb-data \
        mamori-influxdb-conf \
        mamori-grafana
