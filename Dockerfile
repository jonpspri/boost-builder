FROM ubuntu:bionic AS build

SHELL [ "/bin/bash", "-euo", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get -y --no-install-recommends install \
    ca-certificates \
    cmake \
    g++ \
    wget \
 && rm -rf /var/lib/apt/lists/* \
 && :

#
#  Download, compile and install libboost 1.69
#

#  Sorry about this, but docker doesn't like to edit variables
ARG BOOST_VERSION_DOT=1.69.0
ARG BOOST_VERSION_SCORE=1_69_0
COPY boost.sha256 /boost.sha256
RUN echo "Retreiving..." \
  && wget -q \
    https://dl.bintray.com/boostorg/release/${BOOST_VERSION_DOT}/source/boost_${BOOST_VERSION_SCORE}.tar.bz2 \
  && sha256sum -c <(grep ${BOOST_VERSION_SCORE} /boost.sha256) \
  && echo "Expanding..." \
  && tar jxf /boost_${BOOST_VERSION_SCORE}.tar.bz2 \
  && echo "Cleaning up (a little)." \
  && rm /boost_${BOOST_VERSION_SCORE}.tar.bz2

WORKDIR /boost_${BOOST_VERSION_SCORE}
RUN ./bootstrap.sh
RUN ./b2 -j 1 -q install
