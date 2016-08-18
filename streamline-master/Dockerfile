FROM yolo/gpdbdev:centos6

# backport the no-tty fix from RHEL7 to RHEL5
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers

# generate server keys
RUN service sshd start

RUN useradd --password '$5$uitFy1zdHuG$f7NutSS0aAyl7EqqPBhKZOk4iKJzxFkGGYd8s2hERM8' --group adm gpadmin \
	&& echo '%adm ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN chmod g+w -R /opt /usr/local \
	&& chgrp -R adm /opt /usr/local
USER gpadmin

RUN ssh-keygen -f ~/.ssh/id_rsa \
	&& cp ~/.ssh/{id_rsa.pub,authorized_keys}

CMD sudo service sshd start && /bin/bash -l
WORKDIR /build
RUN sudo chown -R gpadmin:gpadmin /build
RUN sudo yum install -q -y ccache
RUN mkdir ~/.ccache
