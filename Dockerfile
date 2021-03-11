FROM openjdk:8
COPY . /usr/src/myapp
WORKDIR /home/airflow
COPY resources /root/folder

ENV ORACLE_HOME=/usr/lib/oracle/11.2/client64
ENV LD_LIBRARY_PATH=${ORACLE_HOME}/lib
ENV TNS_ADMIN=${ORACLE_HOME}/network/admin
ENV PATH=$PATH:/opt/vertica/bin:${ORACLE_HOME}/bin


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
	&& apt-get -y upgrade \
	&& apt-get install -yqq --no-install-recommends \
			$buildDeps \
			freetds-bin \
			build-essential \
			default-libmysqlclient-dev \
			apt-utils \
			curl \
			rsync \
			netcat \
			locales \
	&& apt-get -y install alien \
	&& apt-get -y install sudo \
	&& apt-get -y install libaio1 libaio-dev \
	&& sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
	&& apt-get update \
	&& alien -i /root/folder/vertica-client-9.3.1-0.x86_64.rpm \
	&& alien -i /root/folder/oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm \
	&& apt-get -y install ssh \
	&& service ssh start \
	&& service ssh status \
	&& apt-get clean \
	&& mkdir -p /home/airflow/Java/lib \
	&& cp -R /root/folder/lib /home/airflow/Java/ \
	&& ls /root/folder \
	&& rm -rf /root/folder/* \
	&& useradd -ms /bin/bash -d /home/airflow -p $(openssl passwd -1 brAdebr7) airflow \
	&& chown -R airflow /home/airflow \
	&& mkdir -p /home/airflow/.ssh \
	&& echo "airflow ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
	&& echo "export ORACLE_HOME=$ORACLE_HOME" > /home/airflow/.bashrc \
	&& echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> /home/airflow/.bashrc \
	&& echo "export PATH=$PATH" >> /home/airflow/.bashrc \
	&& echo "export TNS_ADMIN=$TNS_ADMIN" >> /home/airflow/.bashrc \
	&& rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

	
CMD ["java", "Main"]
USER airflow