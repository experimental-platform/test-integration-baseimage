FROM experimentalplatform/ubuntu:latest

RUN apt-get -y update && apt-get -y install openssh-client && rm -rf /var/lib/apt/lists/*

ADD vagrant_1.7.2_x86_64.deb /tmp/vagrant.deb
RUN dpkg -i /tmp/vagrant.deb && \
    rm -rf /tmp/vagrant.deb

RUN vagrant plugin install vagrant-digitalocean
RUN vagrant box add digital_ocean https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box

ADD Vagrantfile /Vagrantfile
ADD cloud-config.yaml /cloud-config.yaml
# RUN curl -sL https://deb.nodesource.com/setup | sudo bash - && \
RUN curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash - && \
    apt-get update && \
    apt-get install -y build-essential curl nodejs git systemd-services python && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g mocha
RUN npm install

ADD initialize.sh /initialize.sh
ADD run_tests.sh /run_tests.sh
RUN chmod 755 /initialize.sh /run_tests.sh


CMD [ "/bin/bash" ]