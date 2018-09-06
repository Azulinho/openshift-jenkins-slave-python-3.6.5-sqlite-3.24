# extend the official jenkins slave base image
FROM openshift/jenkins-slave-base-centos7

# specify wanted version of python
ENV PYTHON_VERSION 3.6.5

# install make deps
RUN set -x \
    && INSTALL_PKGS="gcc make openssl-devel wget zlib-devel" \
    && yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS

# install sqlite
RUN set -x \
    && wget https://www.sqlite.org/2018/sqlite-autoconf-3240000.tar.gz \
    && tar xf sqlite-autoconf-3240000.tar.gz \
    && cd sqlite-autoconf-3240000 \
    && ./configure --prefix=/opt/sqlite/3.24.0 \
    && make \
    && make install \
    && cd .. \
    && rm -rf sqlite-autoconf-3240000*

ENV PATH /opt/sqlite/3.24.0/bin:$PATH

ENV LD_LIBRARY_PATH=/opt/sqlite/3.24.0/lib

# install python
RUN set -x \
    && INSTALL_PKGS="gcc make openssl-devel wget zlib-devel" \
    && chown -R root:root /home/jenkins \
    && cd /tmp \
    && wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
    && tar xzf Python-${PYTHON_VERSION}.tgz \
    && cd Python-${PYTHON_VERSION} \
    && ./configure LDFLAGS="-L/opt/sqlite/3.24.0/lib" CPPFLAGS="-I/opt/sqlite/3.24.0/include" --prefix=/opt/python/3.6.5 \
    && make -j8 install \
    && cd .. \
    && rm -rf Python-${Python_VERSION} \
    && /opt/python/3.6.5/bin/pip3 install virtualenv \
    && yum remove -y $INSTALL_PKGS \
    && yum clean all \
    && chown -R 1001:0 /home/jenkins

RUN find /home/jenkins -type d -exec chmod g+rwx {} \; \
    && find /home/jenkins -type f -exec chmod g+rw {} \;

ENV PATH /opt/python/3.6.5/bin/:$PATH

# switch to non-root for openshift
USER 1001
