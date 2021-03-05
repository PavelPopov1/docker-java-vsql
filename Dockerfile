FROM openjdk:8
COPY . /usr/src/myapp
WORKDIR /home/airflow
COPY resources /root/folder

RUN set -ex \
    && buildDeps=' \
        freetds-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        libpq-dev \
        git \
    ' \
	&& apt-get update \
	&& apt-get -y install alien \
	&& apt-get -y install sudo \
	&& apt-get update \
	&& alien -i /root/folder/vertica-client-9.3.1-0.x86_64.rpm \
	&& echo "export PATH=$PATH:/opt/vertica/bin" >> ~/.bashrc \
	&& apt-get -y install ssh \
	&& service ssh start \
	&& service ssh status \
	&& apt-get -y upgrade \
	&& apt-get clean \
	&& mkdir -p /home/airflow/Java/lib \
	&& echo "export PATH=$PATH:/opt/vertica/bin" >> /home/airflow/.bashrc \
	&& cp -R /root/folder/lib /home/airflow/Java/ \
	&& ls /root/folder \
	&& rm -rf /root/folder/* \
	&& useradd -d /home/airflow -p $(openssl passwd -1 brAdebr7) airflow \
	&& chown -R airflow /home/airflow \
	&& mkdir -p /home/airflow/.ssh \
	&& echo "airflow ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

	
CMD ["java", "Main"]
USER airflow