# python-s2i

##############################################
# ����centos7����python3���л���
# ��������: ��Dockerfile�ļ�Ŀ¼��ִ�� docker build --network=host -t zhiyu-centos7-python38:v1 .
# ������������: docker run -itd --name python --restart always --privileged=true -v /root/dockers/python:/root/python -v /root/dockers/python/cron:/var/spool/cron zhiyu-centos7-python38:v1 /usr/sbin/init
# ����������docker exec -it python /bin/bash
##############################################
FROM centos:7.9.2009
MAINTAINER huiwang # ָ��������Ϣ
WORKDIR /usr/local/app
# COPY requirements.txt .
RUN set -ex \
    # Ԥ��װ�������
    && yum install -y wget tar libffi-devel zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gcc make initscripts \
    && wget https://www.python.org/ftp/python/3.8.12/Python-3.8.12.tgz \
    && tar -zxvf Python-3.8.12.tgz \
    && cd Python-3.8.12 \
    && ./configure prefix=/usr/local/python3 \
    && make \
    && make install \
    && make clean \
    && rm -rf /Python-3.8.12* \
    && yum install -y epel-release \
    && yum install -y python-pip
# ����Ĭ��Ϊpython3
RUN set -ex \
    # ���ݾɰ汾python
    && mv /usr/bin/python /usr/bin/python27 \
    && mv /usr/bin/pip /usr/bin/pip-python27 \
    # ����Ĭ��Ϊpython3
    && ln -s /usr/local/python3/bin/python3.8 /usr/bin/python \	
    && ln -s /usr/local/python3/bin/pip3 /usr/bin/pip
# �޸����޸�python�汾����yumʧЧ����
RUN set -ex \
    && sed -i "s#/usr/bin/python#/usr/bin/python27#" /usr/bin/yum \
    && sed -i "s#/usr/bin/python#/usr/bin/python27#" /usr/libexec/urlgrabber-ext-down \
    && yum install -y deltarpm
# ������������
RUN set -ex \
    # �޸�ϵͳʱ��Ϊ������
    && rm -rf /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && yum install -y vim \
    # ��װ��ʱ�������
    && yum -y install cronie
# ֧������
RUN yum install kde-l10n-Chinese -y
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.utf8
# ����pip�汾
RUN pip install --upgrade pip
# RUN pip install -r /usr/local/app/reqirements.txt
ENV LC_ALL zh_CN.UTF-8
COPY ./s2i/bin/ /usr/libexec/s2i
