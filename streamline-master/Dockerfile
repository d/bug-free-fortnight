FROM ubuntu
RUN apt-get update -q
RUN apt-get install -y \
	openssh-server \
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
	sudo

RUN locale-gen en_US.UTF-8

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

RUN pip install --user \
	psutil \
	lockfile \
	paramiko \
	epydoc

ENV PAGER=less

CMD sudo /usr/sbin/sshd -D
