FROM centos:centos7
#MAINTAINER "grahovsky" <grahovsky@gmail.com>

#Environment Variables

ARG VNC_PORT=9020
ENV VNC_PORT=$VNC_PORT

ENV LANG ru_RU.utf8

# locale
RUN localedef -f UTF-8 -i ru_RU ru_RU.UTF-8

#OKD
ENV OKD_USER_ID 1001080000

RUN groupadd -f --gid $OKD_USER_ID grp1cv8 && \
    useradd --uid $OKD_USER_ID --gid $OKD_USER_ID --comment '1C Enterprise 8 server launcher' --no-log-init --home-dir /home/usr1cv8 usr1cv8

# Perform updates
RUN rpmkeys --import "http://pool.sks-keyservers.net/pks/lookup?op=get&search=0x3fa7e0328081bff6a14da29aa6a19b38d3d831ef" && \
    su -c 'curl https://download.mono-project.com/repo/centos7-stable.repo | tee /etc/yum.repos.d/mono-centos7-stable.repo'

RUN yum -y update && \
    # Install EPEL
    yum -y install epel-release
RUN yum -y install \
    # Install Microsoft's Core Fonts
    curl \
    wget \
    # fonts 
    fontconfig freetype libgsf unixODBC \
    #cabextract \
    xorg-x11-font-utils \
    # Install ImageMagick
    ImageMagick \
    # Install webkitgtk
    webkitgtk3 webkitgtk3-devel \
    # Install mono
    mono-core mono-locale-extras \
    # Install Xvbf
    Xvfb which \
    # Install x11vnc
    x11vnc && \ 
    yum clean all

# copy files
ADD tmp/ /tmp_

# add Xvfb as daemon
# RUN cp /tmp_/config/Xvfb.service /etc/systemd/system/ && \
#     chmod +x /etc/systemd/system/Xvfb.service && \
#     systemctl daemon-reload && systemctl enable Xvfb.service && systemctl start Xvfb.service

# add x11 as daemon
# RUN cp /tmp_/config/x11vnc.service /etc/systemd/system/ && \
#     chmod +x /etc/systemd/system/x11vnc.service && \
#     systemctl daemon-reload && \
#     systemctl enable x11vnc.service && \
#     systemctl start x11vnc.service

# Install rpm
#RUN ls -la /tmp_
#RUN rpm -Uvh /tmp_/rpm/webkitgtk-2.4.9-1.2.x86_64.rpm

#RUN yum install -y webkitgtk2-devel

RUN rpm -Uvh /tmp_/rpm/gtk2-2.24.31-1.el7.x86_64.rpm \ 
    /tmp_/rpm/webkitgtk-2.4.9-1.2.x86_64.rpm

RUN rpm -Uvh /tmp_/rpm/1C_Enterprise83-common-8.3.10-2699.x86_64.rpm \
    /tmp_/rpm/1C_Enterprise83-server-8.3.10-2699.x86_64.rpm \
    /tmp_/rpm/1C_Enterprise83-client-8.3.10-2699.x86_64.rpm

# Install oscript
RUN rpm -Uvh /tmp_/rpm/onescript-engine-1.2.0-1.fc26.noarch.rpm && \
    tar -xcvf /tmp_/oscript.tar.gz /usr/share && \
    chown -R usr1cv8:grp1cv8 /usr/share/oscript && \
    chmod 755 /usr/share/oscript

# Add nethasp
RUN mkdir -p /opt/1C/v8.3/x86_64/conf/
RUN cp /tmp_/config/nethasp.ini /opt/1C/v8.3/x86_64/conf/
RUN chown -R usr1cv8:grp1cv8 /opt/1C

RUN mkdir -p /var/log/1c/dumps/
RUN chown -R usr1cv8:grp1cv8 /var/log/1c/
RUN chmod 755 /var/log/1c

ENV PATH="/opt/1C/v8.3/x86_64:${PATH}"

RUN echo 'root' | passwd root --stdin

VOLUME /var/log/1C

EXPOSE $VNC_PORT

RUN echo "DisableUnsafeActionProtection=.*" >> /opt/1C/v8.3/x86_64/conf/conf.cfg
RUN chown -R usr1cv8:grp1cv8 /opt/1C
RUN chmod -R 777 /opt/1C

#fonts msttcore-fonts-installer-2.6-1.noarch.rpm - error
RUN mkdir -p /home/usr1cv8/.fonts/ && mkdir -p /usr/share/fonts/truetype/ && \
    cp /tmp_/fonts/* /home/usr1cv8/.fonts/ && cp /tmp_/fonts/* /usr/share/fonts/truetype/
RUN chown -R usr1cv8:grp1cv8 /home/usr1cv8/.fonts
RUN fc-cache -fv

USER usr1cv8

Add entrypoint.sh /tmp_/

ENTRYPOINT ["/bin/sh", "-x", "/tmp_/entrypoint.sh"]
#CMD ["xvfb-run sh -c '/opt/1C/v8.3/x86_64/1cv8s'"]
CMD ["1cv8s"]
