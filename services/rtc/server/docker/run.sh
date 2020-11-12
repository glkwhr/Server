#!/usr/bin/env bash

export DEBUG=${DEBUG:="mediasoup:INFO* *WARN* *ERROR*"}
export INTERACTIVE=${INTERACTIVE:="true"}
export PROTOO_LISTEN_PORT=${PROTOO_LISTEN_PORT:="4443"}
export HTTPS_CERT_FULLCHAIN=${HTTPS_CERT_FULLCHAIN:="/service/certs/fullchain.pem"}
export HTTPS_CERT_PRIVKEY=${HTTPS_CERT_PRIVKEY:="/service/certs/privkey.pem"}
export MEDIASOUP_LISTEN_IP=${MEDIASOUP_LISTEN_IP:="0.0.0.0"}
export MEDIASOUP_MIN_PORT=${MEDIASOUP_MIN_PORT:="2000"}
export MEDIASOUP_MAX_PORT=${MEDIASOUP_MAX_PORT:="2020"}

# Valgrind related options.
export MEDIASOUP_USE_VALGRIND=${MEDIASOUP_USE_VALGRIND:="false"}
export MEDIASOUP_VALGRIND_OPTIONS=${MEDIASOUP_VALGRIND_OPTIONS:="--leak-check=full --track-fds=yes --log-file=/storage/mediasoup_valgrind_%p.log"}

#!/bin/bash
if [ 0"$MEDIASOUP_ANNOUNCED_IP" = "0" ]; then
    echo "WARN: env var MEDIASOUP_ANNOUNCED_IP is not set, maybe you should set it in docker envirnment"
fi

docker run \
	--name=trpg-rtc-dev \
	-p ${PROTOO_LISTEN_PORT}:${PROTOO_LISTEN_PORT}/tcp \
	-p ${MEDIASOUP_MIN_PORT}-${MEDIASOUP_MAX_PORT}:${MEDIASOUP_MIN_PORT}-${MEDIASOUP_MAX_PORT}/udp \
	-p ${MEDIASOUP_MIN_PORT}-${MEDIASOUP_MAX_PORT}:${MEDIASOUP_MIN_PORT}-${MEDIASOUP_MAX_PORT}/tcp \
	-v ${PWD}:/storage \
	-v ${MEDIASOUP_SRC}:/mediasoup-src \
	--init \
	-e DEBUG \
	-e INTERACTIVE \
	-e DOMAIN \
	-e PROTOO_LISTEN_PORT \
	-e HTTPS_CERT_FULLCHAIN \
	-e HTTPS_CERT_PRIVKEY \
	-e MEDIASOUP_LISTEN_IP \
	-e MEDIASOUP_ANNOUNCED_IP \
	-e MEDIASOUP_MIN_PORT \
	-e MEDIASOUP_MAX_PORT \
	-e MEDIASOUP_USE_VALGRIND \
	-e MEDIASOUP_VALGRIND_OPTIONS \
	-e MEDIASOUP_WORKER_BIN \
	-it \
	--rm \
	trpg-rtc:dev
