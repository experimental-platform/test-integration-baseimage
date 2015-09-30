FROM experimentalplatform/ubuntu:latest

RUN apt-get -y update && apt-get -y install openssh-client && rm -rf /var/lib/apt/lists/*

RUN FILE=$(mktemp); curl -L https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.4_x86_64.deb > $FILE && dpkg -i $FILE; rm $FILE

RUN vagrant plugin install vagrant-aws
RUN vagrant plugin install aws-sdk
RUN vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box

ADD Vagrantfile /Vagrantfile
ADD cloud-config.yaml /cloud-config.yaml
# RUN curl -sL https://deb.nodesource.com/setup | sudo bash - && \
RUN curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash - && \
    apt-get update && \
    apt-get install -y build-essential curl nodejs git systemd-services python && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD initialize.sh /initialize.sh
RUN chmod 755 /initialize.sh

CMD [ "/bin/bash" ]
