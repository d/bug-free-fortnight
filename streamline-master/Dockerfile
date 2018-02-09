FROM ubuntu:rolling AS base
RUN apt-get update -q
RUN env DEBIAN_FRONTEND=noninteractive apt-get install -y \
	openssh-server \
	krb5-kdc \
	iputils-ping \
	net-tools \
	python-pip \
	gdb \
	g++ \
	make \
	cmake \
	bison \
	flex \
	ccache \
	ninja-build \
	libapr1-dev \
	libevent-dev \
	libxml2-dev \
	libbz2-dev \
	libssl-dev \
	zlib1g-dev \
	python-dev \
	libyaml-dev \
	libperl-dev \
	libreadline-dev \
	libcurl4-gnutls-dev \
	libkrb5-dev \
	locales \
	bzip2 \
	xz-utils \
	runit \
	byobu \
	git \
	rsync \
	patch \
	vim \
	wget \
	gnupg \
	command-not-found \
	unzip \
	pigz \
	iproute2 \
	sudo

RUN locale-gen en_US.UTF-8

RUN pip install \
	psutil \
	lockfile \
	paramiko \
	epydoc

RUN mkdir /var/run/sshd

RUN adduser gpadmin
# enable sudo for gpadmin
RUN adduser gpadmin adm
RUN echo '%adm ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/adm_no_passwd

RUN chmod g+w -R /opt \
	&& chgrp -R adm /opt

WORKDIR /build
RUN chown -R gpadmin:gpadmin /build

USER gpadmin

RUN ssh-keygen -f ~/.ssh/id_rsa -N '' \
	&& cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys

ENV PAGER=less

FROM base AS test
COPY test.bash /
RUN /test.bash

FROM base

LABEL io.github.d.uber-script="oss"
CMD sudo /usr/sbin/sshd -D
