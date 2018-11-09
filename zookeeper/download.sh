#!/bin/bash

path="zookeeper/${DISTRO_NAME}"
url=$(curl --stderr /dev/null "https://www.apache.org/dyn/closer.cgi?path=/${path}&as_json=1" | jq -r '"\(.preferred)\(.path_info)"')

if [[ -z "$url" ]]; then
	echo "Unable to determine mirror for downloading Kafka, the service may be down"
	exit 1
fi

echo $url;

wget -q "${url}/$DISTRO_NAME.tar.gz";
wget -q "${url}/$DISTRO_NAME.tar.gz.asc";
