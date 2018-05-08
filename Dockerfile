FROM centos:7
RUN useradd -ms /bin/bash centos
ADD . /app
WORKDIR /
RUN chmod +x /app/install_dependencies.sh
RUN chmod +x /app/install_app_dependencies.sh
RUN /app/install_dependencies.sh
RUN /app/install_app_dependencies.sh
