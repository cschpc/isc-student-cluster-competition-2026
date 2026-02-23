#!/bin/sh
wget https://ftp.gnu.org/gnu/autoconf/autoconf-2.72.tar.gz
tar xvf autoconf-2.72.tar.gz
INSTALL_DIR=$PWD/autoconf-2.72-install
mkdir $INSTALL_DIR
cd autoconf-2.72
./configure --prefix=$INSTALL_DIR \
       && make \
       && make install \
       && echo "Autoconf installed to $INSTALL_DIR"
