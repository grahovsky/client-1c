FROM centos:centos7 as prepare

ARG ONEC_USERNAME
ARG ONEC_PASSWORD
ARG ONEC_VERSION

ENV installer_type=client

WORKDIR /distr

# RUN apt-get install bash curl grep

# COPY distr/d# COPY distr/fonts.tar.gz fonts.tar.gz
# RUN tar xzf fonts.tar.gzownload.sh /download.sh
# RUN chmod +x /download.sh \
#   && sync; /download.sh

COPY distr .

RUN for file in *.tar.gz; do tar -zxf "$file"; done \
  && rm -rf *.tar.gz

WORKDIR /distr/rpm

RUN for file in *.tar.gz; do tar -zxf "$file"; done \
  && rm -rf *-nls-* *-ws-* *-crs-* \
  && rm -rf *.tar.gz

FROM centos:centos7 as base
#MAINTAINER "grahovsky" <grahovsky@gmail.com>

# Perform updates
# add mono repo
RUN rpmkeys --import "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF" && \
    su -c 'curl https://download.mono-project.com/repo/centos7-stable.repo | tee /etc/yum.repos.d/mono-centos7-stable.repo'

# add liberica java
# RUN gpg --keyserver keys2.kfwebs.net --recv-keys 32e9750179fcea62 \
#     gpg --export -a 32e9750179fcea62 | tee /etc/pki/rpm-gpg/RPM-GPG-KEY-bellsoft > /dev/null
# RUN echo $'[BellSoft] \n\
# name=BellSoft Repository \n\
# baseurl=https://yum.bell-sw.com \n\
# enabled=1 \n\
# gpgcheck=1 \n\
# gpgkey=https://download.bell-sw.com/pki/GPG-KEY-bellsoft \n\
# priority=1' > /etc/yum.repos.d/bellsoft.repo

# Install EPEL
RUN yum -y install epel-release && \
    # Install other package
    yum -y update && yum -y install \
    curl \
    git \
    wget \
    # zip unzip
    zip unzip \
    # xdg open
    xdg-utils \
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
    # Install Xvfb
    Xvfb which \
    # Install dbus-x11
    dbus-x11 \
    # Install x11vnc
    x11vnc \
    # Install java for allure, edt
    # java-11-openjdk \ 
    # bellsoft-java11 \
    ; yum clean all

# Environment Variables
ENV LANG ru_RU.UTF-8
ENV LANGUAGE=ru_RU.UTF-8

# locale
RUN localedef -f UTF-8 -i ru_RU ru_RU.UTF-8

# copy files
COPY --from=prepare /distr /distr

# Install dependences
# RUN rpm -Uvh /distr/rpm/extra/gtk2-2.24.31-1.el7.x86_64.rpm \ 
#     /distr/rpm/extra/webkitgtk-2.4.9-1.2.x86_64.rpm

# OKD
ENV OKD_USER_ID 1001080000
# Add user
RUN groupadd -f --gid $OKD_USER_ID grp1cv8 && \
    useradd --uid $OKD_USER_ID --gid $OKD_USER_ID --comment '1C Enterprise 8 server launcher' --no-log-init --home-dir /home/usr1cv8 usr1cv8
    
# Install 1c
RUN rm /distr/rpm/*thin-client* && yum localinstall -y /distr/rpm/*.rpm && yum clean all

# Install oscript
RUN curl -Lk -o /distr/rpm/extra/onescript.rpm https://github.com/EvilBeaver/OneScript/releases/download/v1.7.0/onescript-engine-1.7.0-1.fc26.noarch.rpm && \
    rpm -Uvh /distr/rpm/extra/onescript.rpm && \
    opm install vanessa-runner gitsync add
     
# Install scrot
RUN yum localinstall -y /distr/rpm/extra/giblib-1.2.4-22.el7.psychotic.x86_64.rpm && \
    rpm -Uvh http://packages.psychotic.ninja/7/base/x86_64/RPMS/psychotic-release-1.0.0-1.el7.psychotic.noarch.rpm && \
    yum -y --enablerepo=psychotic install scrot && \
    yum clean all

# Tuning xvfb-run "no such process" error
RUN sed -i 's/kill \$XVFBPID/\#kill \$XVFBPID/g' /usr/bin/xvfb-run

# Install allure
# RUN tar -zxf /distr/allure_2_12.tgz -C /distr

ENV PLATFORM_PATH=/opt/1C/v8.3/x86_64
ENV CONF_PATH=/opt/1C/v8.3/x86_64/conf
# ENV PLATFORM_PATH=/opt/1cv8/x86_64/8.3.18.1698
# ENV CONF_PATH=/opt/1cv8/x86_64/conf

# Add premission add directory
Run mkdir -p ${CONF_PATH} && chown -R usr1cv8:grp1cv8 ${CONF_PATH} && \
    mkdir /usr/share/fonts/truetype/ && cp /distr/fonts/* /usr/share/fonts/truetype/ && \
    mkdir -p /var/log/1c/ && chown -R usr1cv8:grp1cv8 /var/log/1c && chmod 755 /var/log/1c/ && \
    chmod 777 /etc/hosts

# resolution
ENV RESOLUTION=1920x1080x24

# vnc
ARG VNC_PORT=9000
ENV VNC_PORT=$VNC_PORT

# Expose port vnc
EXPOSE $VNC_PORT

# Add path 1c
ENV PATH="${PLATFORM_PATH}:${PATH}"
# Add path allure
# ENV PATH="/distr/allure_2_12/bin:${PATH}"
# ENV ALLURE_HOME="/distr/allure_2_12"

# Add volume
VOLUME /var/log/1C
# VOLUME /home/usr1cv8

# set rootpass
RUN echo 'root' | passwd root --stdin

# change user
USER usr1cv8

# Add fonts
# fonts msttcore-fonts-installer-2.6-1.noarch.rpm - error
RUN mkdir -p /home/usr1cv8/.fonts/ && cp /distr/fonts/* /home/usr1cv8/.fonts/ && \
    fc-cache -fv

# Add config 1c
ADD /config/ /distr/config/
RUN echo "DisableUnsafeActionProtection=.*" >> ${CONF_PATH}/conf.cfg

# Add nethasp
RUN cp /distr/config/nethasp.ini ${CONF_PATH}

Add entrypoint.sh /tmp/

ENTRYPOINT ["/bin/sh", "-x", "/tmp/entrypoint.sh"]
# for run startup menu 1c
#CMD ["1cv8s"]
