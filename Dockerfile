# https://github.com/ZoneMinder/zmdockerfiles/blob/master/release/ubuntu18.04/Dockerfile
FROM ubuntu:18.04
MAINTAINER Peter Gallagher

# Update base packages
RUN apt update \
    && apt upgrade --assume-yes

# Install pre-reqs
RUN apt install --assume-yes --no-install-recommends gnupg

# Configure Zoneminder PPA
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABE4C7F993453843F0AEB8154D0BF748776FFB04 \
    && echo deb http://ppa.launchpad.net/iconnor/zoneminder-1.34/ubuntu bionic main > /etc/apt/sources.list.d/zoneminder.list \
    && apt update

# Install zoneminder
RUN DEBIAN_FRONTEND=noninteractive apt install --assume-yes zoneminder \
    && a2enconf zoneminder \
    && a2enmod rewrite cgi

# Install zmeventnotification - https://zmeventnotification.readthedocs.io/en/latest/guides/install.html
RUN cd /tmp && apt -y install git && git clone https://github.com/pliablepixels/zmeventnotification.git \
    && cd zmeventnotification && apt-get -y install libyaml-perl && apt-get -y install make &&  apt-get -y install libjson-perl \
    && perl -MCPAN -e "force install Crypt::Eksblowfish::Bcrypt" \
    && perl -MCPAN -e "force install Net::WebSocket::Server" \
    && perl -MCPAN -e "force install LWP::Protocol::https" \
    && perl -MCPAN -e "force install Config::IniFiles" \
    && perl -MCPAN -e "force install Net::MQTT::Simple" \
    && perl -MCPAN -e "force install Net::MQTT::Simple::Auth" \
    && yes | ./install.sh --no-install-hook \
    && chown -R www-data:www-data /var/lib/zmeventnotification/push/

RUN apt-get -y remove make && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /tmp/* /var/tmp/* && \
    mkdir -p /root/zmeventnotification && \
    cp -p /etc/zm/zm.conf /root/zmeventnotification/zm.conf && \
    cp -p /etc/zm/zmeventnotification.ini /root/zmeventnotification/zmeventnotification.ini && \
    cp -p /etc/zm/secrets.ini /root/zmeventnotification/secrets.ini && \
    sed -i '/Enable SSL/!b;n;cenable = no' /root/zmeventnotification/zmeventnotification.ini && \
    sed -i 's/send_event_end_notification = yes/send_event_end_notification = no/g' /root/zmeventnotification/zmeventnotification.ini && \
    sed -i 's/use_hooks = yes/use_hooks = no/g' /root/zmeventnotification/zmeventnotification.ini && \
    sed -i 's/event_end_notify_on_hook_success = fcm,web,api/event_end_notify_on_hook_success = fcm,web,api,mqtt/g' /root/zmeventnotification/zmeventnotification.ini

# Setup Volumes
VOLUME /var/cache/zoneminder/events /var/cache/zoneminder/images /var/lib/mysql /var/log/zm /config
# VOLUME /var/cache/zoneminder/events /var/cache/zoneminder/images /var/lib/mysql /var/log/zm

# Expose http port
EXPOSE 80 9000
# EXPOSE 80

# Configure entrypoint
COPY utils/entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# zm version
# zm:1.34.21
