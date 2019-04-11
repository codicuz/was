#!/bin/bash

if [ ! -f /opt/IBM/WebSphere/wp_profile/bin/startServer.sh ]; then
  tar -C /opt -xvzf /opt/IBM.tgz
fi

/usr/bin/supervisord -c /etc/supervisord.conf
