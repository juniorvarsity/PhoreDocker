FROM ubuntu:bionic AS baseos

# install runtime libraries (Boost, QT5, event, ssl)
# NOTE - use libssl1.0-dev to resolve incompatibility issue

RUN apt-get update && apt-get install -y \
  libboost-filesystem-dev \
  libboost-chrono-dev \
  libboost-program-options-dev \
  libboost-system-dev \ 
  libboost-test-dev \
  libboost-thread-dev \
  libprotobuf-dev \ 
  libqt5core5a \ 
  libqt5dbus5 \ 
  libqt5gui5 \
  protobuf-compiler \
  qttools5-dev \
  qttools5-dev-tools \
  libevent-dev \
  libssl1.0-dev

# Stage to build Phore from source
FROM baseos AS phorebuild

RUN mkdir /phore
ENV BITCOIN_ROOT /phore
WORKDIR ${BITCOIN_ROOT}

RUN apt-get update && apt-get install -y \
  automake \
  autotools-dev \
  build-essential \ 
  bsdmainutils \
  libtool \ 
  pkg-config \
  wget \
  curl

RUN curl -L https://api.github.com/repos/phoreproject/Phore/tarball | tar xzf - --strip 1

# Pick some path to install BDB to, here we create a directory within the phore directory
ENV BDB_PREFIX="$BITCOIN_ROOT/build"
RUN mkdir -p "$BDB_PREFIX"

RUN wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
RUN echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef  db-4.8.30.NC.tar.gz' | sha256sum -c
RUN tar -xzvf db-4.8.30.NC.tar.gz
RUN rm -rf db-4.8.30.NC.tar.gz

WORKDIR db-4.8.30.NC/build_unix/
RUN wget 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD' -O ../dist/config.guess
RUN wget 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD' -O ../dist/config.sub
RUN ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$BDB_PREFIX
RUN make install

WORKDIR ${BITCOIN_ROOT}

RUN ./autogen.sh
RUN ./configure LDFLAGS="-L${BDB_PREFIX}/lib/" CPPFLAGS="-I${BDB_PREFIX}/include/"

RUN make
RUN make install

# final stage, copy Phore runtime files and set to launch when running the image
FROM baseos AS phoreruntime

COPY --from=phorebuild /usr/local/bin/phore-* /usr/local/bin/
CMD ["/usr/local/bin/phore-qt"]




