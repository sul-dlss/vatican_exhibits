FROM centos:7
RUN useradd -ms /bin/bash centos
ADD . /app
WORKDIR /app
RUN chmod +x /app/install.sh
RUN /app/install.sh
