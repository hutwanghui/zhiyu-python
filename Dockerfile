# python-s2i

##############################################
# 基于centos7构建python3运行环境
# 构建命令: 在Dockerfile文件目录下执行 docker build --network=host -t zhiyu-centos7-python38:v1 .
# 容器启动命令: docker run -itd --name python --restart always --privileged=true -v /root/dockers/python:/root/python -v /root/dockers/python/cron:/var/spool/cron zhiyu-centos7-python38:v1 /usr/sbin/init
# 进入容器：docker exec -it python /bin/bash
##############################################
FROM centos:7.9.2009
MAINTAINER huiwang # 指定作者信息
WORKDIR /usr/local/app
# COPY requirements.txt .
RUN set -ex \
    # 预安装所需组件
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
# 设置默认为python3
RUN set -ex \
    # 备份旧版本python
    && mv /usr/bin/python /usr/bin/python27 \
    && mv /usr/bin/pip /usr/bin/pip-python27 \
    # 配置默认为python3
    && ln -s /usr/local/python3/bin/python3.8 /usr/bin/python \	
    && ln -s /usr/local/python3/bin/pip3 /usr/bin/pip
# 修复因修改python版本导致yum失效问题
RUN set -ex \
    && sed -i "s#/usr/bin/python#/usr/bin/python27#" /usr/bin/yum \
    && sed -i "s#/usr/bin/python#/usr/bin/python27#" /usr/libexec/urlgrabber-ext-down \
    && yum install -y deltarpm
# 基础环境配置
RUN set -ex \
    # 修改系统时区为东八区
    && rm -rf /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && yum install -y vim \
    # 安装定时任务组件
    && yum -y install cronie
# 支持中文
RUN yum install kde-l10n-Chinese -y
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.utf8
# 更新pip版本
RUN pip install --upgrade pip
# RUN pip install -r /usr/local/app/reqirements.txt
ENV LC_ALL zh_CN.UTF-8
COPY ./s2i/bin/ /usr/libexec/s2i
