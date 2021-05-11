FROM ubuntu

RUN apt-get update \
  && apt-get install -y iproute2 iperf3
  
#RUN apt-get install -y --fix-missing openssh-server \
#  && rm -rf /var/lib/apt/lists/*

WORKDIR /server/

ADD server.sh /server/

