FROM ubuntu:latest

ENV DB2_INST_DIR expc
ENV DB2_VERSION 10.5.0.4
ENV DB2_RESP_FILE db2expc.rsp
ENV DB2_DIR /opt/ibm/db2/V10.5

RUN dpkg --add-architecture i386 && apt-get update
RUN apt-get install -y libaio1 libpam-ldap:i386 libstdc++6-4.7-pic lib32stdc++6 libxml2

ADD v10.5_linuxx64_expc.tar.gz /tmp/
COPY ${DB2_RESP_FILE} /tmp/${DB2_RESP_FILE}

RUN cd /tmp/${DB2_INST_DIR} && \
./db2prereqcheck -v ${DB2_VERSION} && \
( ./db2setup -r /tmp/${DB2_RESP_FILE} && \
cat /tmp/db2setup.log || cat /tmp/db2setup.log ) && \
${DB2_DIR}/bin/db2val -o && \
cd && \
rm -Rf /tmp/${DB2_INST_DIR} && \
rm /tmp/${DB2_RESP_FILE}

RUN groupadd db2grp1 && useradd -g db2grp1 -d /home/db2inst1 -m -s /bin/bash db2inst1 && echo "db2inst1:db2inst1" | chpasswd

RUN /opt/ibm/db2/V10.5/instance/db2icrt -u db2inst1 -p 50000 db2inst1

EXPOSE 50000

CMD sysctl kernel.shmmax=18446744073692774399 \
 && su - db2inst1 -c "source /home/db2inst1/sqllib/db2profile && db2start && db2 create database sample"

