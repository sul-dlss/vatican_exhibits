FROM centos:7
RUN useradd -ms /bin/bash centos
WORKDIR /
RUN echo "root:root" | chpasswd
RUN echo "centos:centos" | chpasswd
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

ADD system-setup/000-system-setup.sh /app/000-system-setup.sh
RUN chmod +x /app/000-system-setup.sh
RUN /app/000-system-setup.sh

ADD system-setup/001-install-rvm.sh /app/001-install-rvm.sh
RUN chmod +x /app/001-install-rvm.sh
RUN /app/001-install-rvm.sh

ADD system-setup/009-download-solr.sh /app/009-download-solr.sh
RUN chmod +x /app/009-download-solr.sh
RUN /app/009-download-solr.sh

ADD system-setup/010-install_dependencies.sh /app/010-install_dependencies.sh
RUN chmod +x /app/010-install_dependencies.sh
RUN /app/010-install_dependencies.sh

ADD system-setup/100-install_app_dependencies.sh /app/100-install_app_dependencies.sh
RUN chmod +x /app/100-install_app_dependencies.sh
USER centos
RUN /app/100-install_app_dependencies.sh

USER root
ADD system-setup/999-new-stuff.sh /app/999-new-stuff.sh
RUN chmod +x /app/999-new-stuff.sh
RUN /app/999-new-stuff.sh

ENV container docker
ADD system-setup/cmd.sh /app/cmd.sh
RUN chmod +x /app/cmd.sh
ADD system-setup/first-run.sh /app/first-run.sh
RUN chmod +x /app/first-run.sh
CMD ["/app/cmd.sh"]
