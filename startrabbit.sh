#!/bin/bash

/usr/bin/hostname | awk -F "-" '{print "NODENAME=rabbit@"$1}' > /etc/rabbitmq/rabbitmq-env.conf
NODE=$(/usr/bin/hostname | awk -F "-" '{print $1}')


sleep 2

if [ -z "$CLUSTERED" ]; then
	# if not clustered then start it normally as if it is a single server
	/usr/sbin/rabbitmq-server	
else
	if [ -z "$CLUSTER_WITH" ]; then
		# If clustered, but cluster with is not specified then again start normally, could be the first server in the
		# cluster
		/usr/sbin/rabbitmq-server
	else
		/usr/sbin/rabbitmq-server -detached
		rabbitmqctl stop_app
		if [ -z "$RAM_NODE" ]; then
			rabbitmqctl join_cluster rabbit@$CLUSTER_WITH
		else
			rabbitmqctl join_cluster --ram rabbit@$CLUSTER_WITH
		fi
		rabbitmqctl start_app

		# Tail to keep the a foreground process active..
		tail -f /var/log/rabbitmq/rabbit\@$NODE.log
	fi
fi

