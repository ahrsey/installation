FROM ubuntu:latest

RUN apt-get update 
RUN apt-get install -y sudo bash ca-certificates

# RUN useradd -rm -d /home/test -s /bin/bash -G sudo -u 1000 test 
# RUN usermod -aG sudo test
# RUN echo 'test:test' | chpasswd

# Copy files for testing
ADD install.sh /
ADD uninstall.sh /
ADD update.sh /
ADD config.sh /
RUN chmod +x /install.sh
RUN chmod +x /uninstall.sh
RUN chmod +x /update.sh
RUN chmod +x /config.sh

EXPOSE 69

ENTRYPOINT ["tail", "-f", "/dev/null"]
