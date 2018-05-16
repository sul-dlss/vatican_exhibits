#!/bin/bash

# NOTE: This is the entry point for the docker container. The
# init script below sets up systemd and all its registered services
exec /usr/sbin/init
