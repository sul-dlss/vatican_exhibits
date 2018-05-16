FROM centos/systemd
MAINTAINER "SUL DLSS Access Team" <dlss-access-team@lists.stanford.edu>

ENV container docker
RUN useradd -ms /bin/bash centos
WORKDIR /
RUN echo "root:root" | chpasswd ; \
    echo "centos:centos" | chpasswd

RUN mkdir /app

COPY system-setup/000-system-setup.sh /app/000-system-setup.sh
RUN chmod +x /app/000-system-setup.sh \
    && /app/000-system-setup.sh

COPY system-setup/001-install-rvm.sh /app/001-install-rvm.sh
RUN chmod +x /app/001-install-rvm.sh \
    && /app/001-install-rvm.sh

COPY system-setup/009-download-solr.sh /app/009-download-solr.sh
RUN chmod +x /app/009-download-solr.sh \
     && /app/009-download-solr.sh

COPY system-setup/010-install_dependencies.sh /app/010-install_dependencies.sh
RUN chmod +x /app/010-install_dependencies.sh \
    && /app/010-install_dependencies.sh

RUN yum clean all

COPY system-setup/100-install_app_dependencies.sh /app/100-install_app_dependencies.sh
RUN chmod +x /app/100-install_app_dependencies.sh

USER centos
RUN /app/100-install_app_dependencies.sh

USER root
COPY system-setup/999-new-stuff.sh /app/999-new-stuff.sh
RUN chmod +x /app/999-new-stuff.sh \
    && /app/999-new-stuff.sh

COPY system-setup/first-run.sh /app/first-run.sh
RUN chmod +x /app/first-run.sh

COPY system-setup/cmd.sh /app/cmd.sh
RUN chmod +x /app/cmd.sh

EXPOSE 80
CMD ["/app/cmd.sh"]
