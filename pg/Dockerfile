FROM ubuntu:trusty
# trusty is for old people, yes, but there's a stupid Postgres bug that wasn't
# fixed until May 2016. And it wasn't backported to versions before 9.1. See
# postgres/postgres@7d7b129277eb545286aecf29ec22b5bb7fdf46bd and
# postgres/postgres@32f15d05c80044335f97347b5406f6736c06a033
RUN apt-get update -q
RUN apt-get install -y \
	gdb \
	ccache \
	make \
	gcc \
	bison \
	flex \
	vim \
	zlib1g-dev \
	libreadline-dev \
	runit \
	byobu \
	git \
	rsync

ENV PGDATA /var/lib/postgresql/data
RUN adduser postgres
RUN mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA"
