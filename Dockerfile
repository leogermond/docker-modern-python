FROM python:3-slim-buster

# Mark and install temp APT packages
RUN savedAptMark="$(apt-mark showmanual)" \
 && apt-get update
RUN apt-get install -y --no-install-recommends \
      git \
      dpkg-dev \
      gcc \
      libbluetooth-dev \
      libbz2-dev \
      libc6-dev \
      libexpat1-dev \
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

ENV PYENV_ROOT $HOME/.pyenv
RUN git clone https://github.com/pyenv/pyenv.git $PYENV_ROOT
ENV PATH $PYENV_ROOT/bin:$PATH

RUN for version in \
        3.6.11 \
        3.7.8 \
#       3.8.5 (default system version)
        3.9-dev \
  ; do pyenv install -v $version; done

# Remove temp APT packages
RUN apt-mark auto '.*' > /dev/null \
 && apt-mark manual $savedAptMark \
 && find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec ldd '{}' ';' \
 	| awk '/=>/ { print $(NF-1) }' \
 	| sort -u \
 	| xargs -r dpkg-query --search \
 	| cut -d: -f1 \
 	| sort -u \
 	| xargs -r apt-mark manual \
 && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*

RUN pip install tox flake8 tox-pyenv
