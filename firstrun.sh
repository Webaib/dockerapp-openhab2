#!/bin/bash
if [ ! -d /config/addons ]; then
	echo '******MOVING**********'
	mv /opt/openhab/conf /config/
	#mv /opt/openhab/webapps /config/
	#mv /opt/openhab/configurations /config/

	echo '******LINKING**********'
	ln -s /config/conf /opt/openhab/conf
	#ln -s /config/webapps /opt/openhab/webapps
	#ln -s /config/configurations /opt/openhab/configurations

	chown -R openhab:openhab /config
	chmod -R 777 /config
fi

# Remove any lock files
rm -f /var/lock/LCK.*
