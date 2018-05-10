FROM centos:7
RUN useradd -ms /bin/bash centos
WORKDIR /

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

RUN mkdir /app
ADD install_dependencies.sh /app/install_dependencies.sh
RUN chmod +x /app/install_dependencies.sh
RUN /app/install_dependencies.sh
ADD install_app_dependencies.sh /app/install_app_dependencies.sh
RUN chmod +x /app/install_app_dependencies.sh
USER centos
RUN /app/install_app_dependencies.sh
USER root
ENV container docker
CMD ["/usr/sbin/init"]
