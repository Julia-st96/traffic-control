#!/bin/bash

DEV="eth0"

START_RATE=5mbit
LIMIT_RATE=110mbit

CHILD_LIMIT_RATE_1=40mbit
CHILD_LIMIT_RATE_2=20mbit
CHILD_LIMIT_RATE_3=20mbit
CHILD_LIMIT_RATE_4=20mbit
DEFAULT_LIMIT_RATE=10mbit

DST_IP_1=172.28.1.1
DST_IP_2=172.28.1.2
DST_IP_3=172.28.1.3
DST_IP_4=172.28.1.4

clean() {
  echo "== CLEAN INIT =="
  tc qdisc del dev $DEV root
  echo "== CLEAN INIT =="
}

create() {
  echo "== SHAPING INIT =="

  tc qdisc add dev $DEV root handle 1:0 \
    htb default 99
    
  tc class add dev $DEV parent 1:0 classid 1:1 \
    htb rate $LIMIT_RATE

  tc class add dev $DEV parent 1:1 classid 1:10 \
    htb rate $START_RATE ceil $CHILD_LIMIT_RATE_1
  tc class add dev $DEV parent 1:1 classid 1:20 \
    htb rate $START_RATE ceil $CHILD_LIMIT_RATE_2
  tc class add dev $DEV parent 1:1 classid 1:30 \
    htb rate $START_RATE ceil $CHILD_LIMIT_RATE_3
  tc class add dev $DEV parent 1:1 classid 1:40 \
    htb rate $START_RATE ceil $CHILD_LIMIT_RATE_4
  tc class add dev $DEV parent 1:1 classid 1:99 \
    htb rate $START_RATE ceil $DEFAULT_LIMIT_RATE
    
  tc class add dev $DEV parent 1:20 classid 1:201 \
    htb rate $START_RATE ceil $CHILD_LIMIT_RATE_2
  tc class add dev $DEV parent 1:20 classid 1:202 \
    htb rate $START_RATE ceil $CHILD_LIMIT_RATE_2
  
  # by dst IP
  tc filter add dev $DEV protocol ip parent 1:0 prio 1 u32 \
    match ip dst $DST_IP_1 flowid 1:10
  tc filter add dev $DEV protocol ip parent 1:0 prio 1 u32 \
    match ip dst $DST_IP_3 flowid 1:30
  tc filter add dev $DEV protocol ip parent 1:0 prio 1 u32 \
    match ip dst $DST_IP_4 flowid 1:40
    
  # UDP for client 2
  tc filter add dev $DEV protocol ip parent 1:0 prio 1 u32 \
    match ip dst $DST_IP_2 \
    match ip protocol 17 0xff \
    flowid 1:201
  # else for client 2
  tc filter add dev $DEV protocol ip parent 1:0 prio 2 u32 \
    match ip dst $DST_IP_2 flowid 1:202

  echo "== SHAPING DONE =="
}

check() {
  echo "==TO CLIENT 1 START=="
  iperf3 -c $DST_IP_1 -p 8080 -t 10
  echo "==TO CLIENT 1 FINISH=="
  
  echo "==TO CLIENT 2 START=="
  iperf3 -c $DST_IP_2 -p 8080 -t 10
  echo "==TO CLIENT 2 FINISH=="
  
  echo "==TO CLIENT 3 START=="
  iperf3 -c $DST_IP_3 -p 8080 -t 10
  echo "==TO CLIENT 3 FINISH=="
  
  echo "==TO CLIENT 4 START=="
  iperf3 -c $DST_IP_4 -p 8080 -t 10
  echo "==TO CLIENT 4 FINISH=="
}

clean
create
check

