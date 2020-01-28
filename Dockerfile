FROM centos:centos7
#MAINTAINER "grahovsky" <grahovsky@gmail.com>

# Environment Variables
ENV LANG ru_RU.utf8

# locale
RUN localedef -f UTF-8 -i ru_RU ru_RU.UTF-8

# Perform updates
RUN rpmkeys --import "http://pool.sks-keyservers.net/pks/lookup?op=get&search=0x3fa7e0328081bff6a14da29aa6a19b38d3d831ef" && \
    su -c 'curl https://download.mono-project.com/repo/centos7-stable.repo | tee /etc/yum.repos.d/mono-centos7-stable.repo'

# Install EPEL
RUN yum -y update; yum -y install epel-release; yum clean all
# Install other package
RUN yum -y update; yum -y install \
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
    # Install Xvfb
    Xvfb which \
    # Install x11vnc
    x11vnc; \ 
    yum clean all

# copy files
ADD distrib/ /distrib/

# Install dependences
RUN rpm -Uvh /distrib/rpm/gtk2-2.24.31-1.el7.x86_64.rpm \ 
    /distrib/rpm/webkitgtk-2.4.9-1.2.x86_64.rpm

# OKD
ENV OKD_USER_ID 1001080000
# Add user
RUN groupadd -f --gid $OKD_USER_ID grp1cv8 && \
    useradd --uid $OKD_USER_ID --gid $OKD_USER_ID --comment '1C Enterprise 8 server launcher' --no-log-init --home-dir /home/usr1cv8 usr1cv8
    
# Install 1c
RUN rpm -Uvh /distrib/rpm/1C_Enterprise83-common-8.3.10-2699.x86_64.rpm \
    /distrib/rpm/1C_Enterprise83-server-8.3.10-2699.x86_64.rpm \
    /distrib/rpm/1C_Enterprise83-client-8.3.10-2699.x86_64.rpm

# Install oscript
RUN rpm -Uvh /distrib/rpm/onescript-engine-1.2.0-1.fc26.noarch.rpm && \
    tar -zxvf /distrib/oscript.tar.gz -C /usr/share

# Add premission add directory
Run mkdir /opt/1C/v8.3/x86_64/conf/ && chown -R usr1cv8:grp1cv8 /opt/1C/v8.3/x86_64/conf/ && \
    mkdir /usr/share/fonts/truetype/ && cp /distrib/fonts/* /usr/share/fonts/truetype/ && \
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
ENV PATH="/opt/1C/v8.3/x86_64:${PATH}"

# Add volume
VOLUME /var/log/1C
#VOLUME /home/usr1cv8

# set rootpass
RUN echo 'root' | passwd root --stdin

# change user
USER usr1cv8

# Add fonts
#fonts msttcore-fonts-installer-2.6-1.noarch.rpm - error
RUN mkdir -p /home/usr1cv8/.fonts/ && cp /distrib/fonts/* /home/usr1cv8/.fonts/ && \
    fc-cache -fv

# Add config 1c
ADD /config/ /distrib/config/
RUN echo "DisableUnsafeActionProtection=.*" >> /opt/1C/v8.3/x86_64/conf/conf.cfg

# Add nethasp
RUN mkdir -p  /opt/1C/v8.3/x86_64/conf/ && cp /distrib/config/nethasp.ini /opt/1C/v8.3/x86_64/conf/

Add entrypoint.sh /tmp/

ENTRYPOINT ["/bin/sh", "-x", "/tmp/entrypoint.sh"]
CMD ["1cv8s"]
