FROM python:3-slim-buster
ARG TEST_IMAGE=0

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
# Temp APT packages (save others to ~/apt-prev-manual)
RUN apt-mark showmanual > ~/apt-prev-manual \
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
      $(command -v gpg > /dev/null || echo 'gnupg dirmngr')

# pyenv install
ENV PYENV_ROOT $HOME/.pyenv
RUN git clone https://github.com/pyenv/pyenv.git $PYENV_ROOT
ENV PATH $PYENV_ROOT/bin:$PATH

#       3.8.5 is default system version
RUN PYENV_VERSION_=" \
        system \
        3.7.8 \
        3.6.11 \
        3.9-dev \
    " \
 && for version in $PYENV_VERSION_; do \
      if [ "$version" != "system" ]; then \
          PYTHON_CONFIGURE_OPTS=" \
            --enable-option-checking=fatal \
            --enable-shared \
            --with-system-expat \
            --with-system-ffi \
            --without-ensurepip \
            --enable-optimizations \
           " \
          pyenv install -v $version; \
      fi; \
    done \
# PYENV_VERSION env variable is a bit overkill for most usages, simply set
# them as global versions
 && pyenv global $PYENV_VERSION_

# Strip executables
RUN find / -executable -type f -exec strip --strip-all {} \; 2>/dev/null \
# ...and l__pycache__ibs
 && find / \( -type f -a \( -name "*.a" -o -name "*.so" \) \
         \) -exec strip --strip-all {} \; 2>/dev/null

# Remove temp APT packages
RUN apt-mark auto '.*' > /dev/null \
 && apt-mark manual $(cat ~/apt-prev-manual) \
 && rm ~/apt-prev-manual \
 && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
 && rm -rf /var/lib/apt/lists/*

# clear python build temp and test files
RUN find / -name __pycache__ -type d -prune -exec rm -rf {} \; \
 && find / -name "*.py[co]" -type f -exec rm -rf {} \; \
 && find / -name  "*.[oc]" -type f -exec rm -rf {} \; \
 && find $PYENV_ROOT \
       \( \( -name test -o -name tests -o -name idle_test \) -a -type d \) \
       -prune -exec rm -rf {} \;

RUN pip install --upgrade pip \
 && pip install tox flake8 tox-pyenv

CMD ["python"]
