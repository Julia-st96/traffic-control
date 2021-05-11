FROM ubuntu

RUN apt-get update \
  && apt-get install -y iproute2 iperf3
    
#RUN apt-get install -y openssh-client

WORKDIR /client/

ADD client.sh /client/

