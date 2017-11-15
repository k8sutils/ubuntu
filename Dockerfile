FROM ubuntu:16.04
# really from: github.com/Nordstrom/baseimage-ubuntu-docker

ENV DEBIAN_FRONTEND=noninteractive

# configure dpkg
RUN mkdir -p /etc/dpkg/dpkc.cfg.d
RUN echo 'path-exclude /usr/share/doc/* \n \
    path-include /usr/share/doc/*/copyright \n \
    path-exclude /usr/share/man/* \n \
    path-exclude /usr/share/groff/* \n \
    path-exclude /usr/share/info/* \n \
    path-exclude /usr/share/locale/* \n \
    path-include /usr/share/locale/en_US* \n \
    path-include /usr/share/locale/locale.alias \n \
    path-exclude /usr/share/i18n/locales/* \n \
    path-include /usr/share/i18n/locales/en_US*' > /etc/dpkg/dpkc.cfg.d/excludes

# removes the need for systemd-sysv
RUN echo '#!/bin/sh \nexit 0' > runlevel

RUN apt-get update \
    && apt-get dist-upgrade -y

# apparently apt is needed to apt-get purge itself
RUN apt-mark hold apt gnupg adduser passwd libsemanage1
RUN echo "Yes, do as I say!" | apt-get purge \
    e2fslibs \
    libcap2-bin \
    libkmod2 \
    libmount1 \
    libncursesw5 \
    libprocps4 \
    libsmartcols1 \
    libudev1 \
    ncurses-base \
    ncurses-bin \
    locales \
    tzdata \
    systemd \
    libsystemd0

# rm all the things
RUN apt-get autoremove -y && \
    apt-get clean -y && \
    tar -czf /usr/share/copyrights.tar.gz /usr/share/common-licenses /usr/share/doc/*/copyright && \
    rm -rf \
        /usr/share/doc \
        /usr/share/man \
        /usr/share/info \
        /usr/share/locale \
        /var/lib/apt/lists/* \
        /var/log/* \
        /var/cache/debconf/* \
        /usr/share/common-licenses* \
        ~/.bashrc \
        /etc/systemd \
        /lib/lsb \
        /lib/udev \
        /usr/lib/x86_64-linux-gnu/gconv/IBM* \
        /usr/lib/x86_64-linux-gnu/gconv/EBC* && \
    mkdir -p /usr/share/man/man1 /usr/share/man/man2 \
        /usr/share/man/man3 /usr/share/man/man4 \
        /usr/share/man/man5 /usr/share/man/man6 \
        /usr/share/man/man7 /usr/share/man/man8

# wipe apt
RUN echo 'APT::Post-Invoke { "rm -f /var/lib/apt/lists/* /tmp/* /var/tmp/* || true"; }; \n \
    APT::Clean "always"; \n \
    APT::Install-Recommends "false"; \n \
    APT::Install-Suggests "false";' > /etc/apt/apt.conf.d/clean

RUN apt-get update -qy
RUN apt-get install -qyf curl dnsutils

WORKDIR /

CMD [ "/bin/bash", "-c", "--", "while true; do sleep 30; done;"]
