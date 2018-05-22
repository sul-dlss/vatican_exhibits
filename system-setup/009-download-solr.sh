#!/bin/bash

# Echo the commands as they run
set -x #echo on

# Download solr from a randomly chosen mirror
# (Note: this will need updating after new solr releases)
curl -O http://apache.claz.org/lucene/solr/7.3.1/solr-7.3.1.tgz
