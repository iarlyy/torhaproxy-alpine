#!/bin/sh
set -e

TOR_PROCS_NUM=${TOR_PROCS_NUM:-1}
TOR_IP_ROTATION_INTERVAL=${TOR_IP_ROTATION_INTERVAL:-60}
TOR_ROOTDIR="/tor"
HAPROXY_CONF_PATH="/haproxy.conf"

if [ -z "$1" ]; then
  for t in `seq 1 ${TOR_PROCS_NUM}`
    do
      mkdir -p ${TOR_ROOTDIR}/$t
      TOR_HTTP_PORT=`expr 8000 + $t`
      TOR_SOCKS5_PORT=`expr 9000 + $t`
      echo "Starting $t/${TOR_PROCS_NUM} - port: ${TOR_HTTP_PORT}"
      cat > torrc-$t <<EOF
SOCKSPort 0.0.0.0:${TOR_SOCKS5_PORT}
HTTPTunnelPort 0.0.0.0:${TOR_HTTP_PORT}
MaxCircuitDirtiness ${TOR_IP_ROTATION_INTERVAL}
DataDirectory ${TOR_ROOTDIR}/$t
EOF
      echo -e "\tserver tor$t localhost:${TOR_HTTP_PORT}" >> ${HAPROXY_CONF_PATH}

      tor --RunAsDaemon 1 -f /torrc-$t

    done
  set -- haproxy -f /haproxy.conf "$@"
fi

exec "$@"
