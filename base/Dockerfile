FROM python:3-slim-buster
ARG TEST_IMAGE=0
ARG OPTIMIZE=0
ARG PYENV_VERSION="3.9.0"

# keep tests files only on TEST_IMAGE != 0
COPY tests tests
RUN if [ $TEST_IMAGE -eq 0 ]; then \
      rm -rf tests; \
    else \
      echo "Test image:" \
      && ls -lAp tests; \
    fi

# Necessary APT packages
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      libexpat1-dev

# pyenv install
ENV PYENV_ROOT /.pyenv
ENV PATH $PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH
RUN set -xe \
 && apt-mark showmanual > ~/apt-prev-manual \
 # temp apt packages
 && apt-get install -y --no-install-recommends \
      git \
      dpkg-dev \
      gcc \
      libbluetooth-dev \
      libbz2-dev \
      libc6-dev \
      libffi-dev \
      libgdbm-dev \
      liblzma-dev \
      libncursesw5-dev \
      libreadline-dev \
      libsqlite3-dev \
      libssl-dev \
      make \
      tk-dev \
      uuid-dev \
      wget \
      xz-utils \
      zlib1g-dev \
      # as of Stretch, "gpg" is no longer included by default
      $(command -v gpg > /dev/null || echo 'gnupg dirmngr') \
 && git clone https://github.com/pyenv/pyenv.git $PYENV_ROOT \
 && export PYTHON_CONFIGURE_OPTS=" \
       --enable-option-checking=fatal \
       --enable-shared \
       --with-system-expat \
       --with-system-ffi \
       --without-ensurepip \
       " \
 && export PYTHON_CFLAGS=" \
      -Os \
    " \
 && export MAKE_OPT=" \
      LDFLAGS=\"-Wl,--strip-all\" \
    " \
 && if [ $OPTIMIZE -ne 0 ]; then \
      export PYTHON_CONFIGURE_OPTS=" \
      $PYTHON_CONFIGURE_OPTS \
      --enable-optimizations"; \
    fi \
 && pyenv install -v $PYENV_VERSION \
 # PYENV_VERSION env variable is a bit overkill for most usages, simply set
 # them as global versions
 && pyenv global $PYENV_VERSION \
 # Strip executables and libs
 && find / -type f -a \( -executable -o -name "*.so" \) \
          -exec strip --strip-all {} \; 2>/dev/null \
# clear python build temp and test files
 && find / -name __pycache__ -type d -prune -exec rm -rf {} \; \
 && find / -name  "*.[oc]" -type f -exec rm -rf {} \; \
 && find / -type f -a \( -name "*.py[co]" -o -name "*.a" -o -name "*.exe" \) \
           -exec rm -rf {} \; \
 && ldconfig \
 && find $PYENV_ROOT \
       \( \( -name test -o -name tests -o -name idle_test \) -a -type d \) \
       -prune -exec rm -rf {} \; \
 && rm -rf $PYENV_ROOT/.git \
 # probably not possible to build any new python from there on...
 && rm -rf $PYENV_ROOT/plugins/python-build \
 # Remove install APT packages
 && apt-mark auto '.*' > /dev/null \
 && apt-mark manual $(cat ~/apt-prev-manual) \
 && find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec ldd '{}' ';' \
 	| awk '/=>/ { print $(NF-1) }' \
 	| sort -u \
 	| xargs -r dpkg-query --search \
 	| cut -d: -f1 \
 	| sort -u \
 	| xargs -r apt-mark manual \
 && rm ~/apt-prev-manual \
 && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* \
 && find -name "*.log" -delete

CMD ["python"]
