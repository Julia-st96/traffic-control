#!/bin/bash

DEV="eth0"

SRC_IP_3=172.28.1.3

clean() {
  echo "== CLEAN INIT =="
  tc qdisc del dev $DEV root
  echo "== CLEAN INIT =="
}

create() {
  echo "== SHAPING INIT =="

  tc qdisc add dev $DEV root handle 1:0 \
    htb default 99
   
  # ignor ICMP
  tc filter add dev $DEV protocol ip parent 1:0 prio 0 u32 \
    match ip protocol 1 0xff \
    action drop

  # ignor SSH from client 3
  tc filter add dev $DEV protocol ip parent 1:0 prio 0 u32 \
    match ip protocol 6 0xff \
    match ip sport 22 0xffff \
    match ip src $SRC_IP_3 \
    action drop

  echo "== SHAPING DONE =="
}

check() {
  echo "== LISTENING START =="
  iperf3 -s -p 8080 --one-off
  echo "== LISTENING FINISH =="
}

clean
create
check

