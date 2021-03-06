#!/bin/bash
#
# RelEx install script for Ubuntu/Debian systems
# Tested on Ubuntu 12.04 LTS (Precise Pangolin)
# Tested on Ubuntu 14.04 LTS (Trusty Tahr)
#
# Usage:
#   git clone https://github.com/opencog/relex
#   cd relex
#   install-scripts/install-ubuntu-dependencies.sh
#     (note: will ask for sudo password)
#   ant run
#
# Authors: David Hart, Cosmo Harrigan

# Ubuntu/Debian Packages
sudo apt-get -y update 
sudo apt-get -y install build-essential unzip wget
sudo apt-get -y install wordnet-dev wordnet-sense-index
sudo apt-get -y install openjdk-7-jdk 
sudo apt-get -y install ant libcommons-logging-java libgetopt-java

# Link Grammar
wget http://www.abisource.com/downloads/link-grammar/4.8.6/link-grammar-4.8.6.tar.gz
tar -xvf link-grammar-4.8.6.tar.gz
rm link-grammar-4.8.6.tar.gz
cd link-grammar-4.8.6
JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64  ./configure 
make 
sudo make install
sudo ln -v -s /usr/local/lib/liblink-grammar.so.4 /usr/lib/liblink-grammar.so.4
cd ..

# Java WordNet Library
wget http://downloads.sourceforge.net/project/jwordnet/jwnl/JWNL%201.4/jwnl14-rc2.zip
unzip jwnl14-rc2.zip jwnl14-rc2/jwnl.jar
sudo mv -v jwnl14-rc2/jwnl.jar /usr/local/share/java/
rm -v jwnl14-rc2.zip && rmdir jwnl14-rc2
sudo chmod -v 0644 /usr/local/share/java/jwnl.jar 
