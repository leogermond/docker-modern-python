FROM sawertyu/modern_python:3.6 as base-36
FROM sawertyu/modern_python:3.7 as base-37
FROM sawertyu/modern_python:3.8 as base-38
FROM sawertyu/modern_python:3.9 as base-39
FROM sawertyu/modern_python:3.10 as base-all

COPY --from=base-36 $PYENV_ROOT/versions/ /tmp
COPY --from=base-37 $PYENV_ROOT/versions/ /tmp
COPY --from=base-38 $PYENV_ROOT/versions/ /tmp
COPY --from=base-39 $PYENV_ROOT/versions/ /tmp

RUN set -xe \
 && cp -r tmp/* $PYENV_ROOT/versions

FROM python:3-slim-buster

ENV PYENV_ROOT /.pyenv
ENV PATH $PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH

COPY --from=base-all $PYENV_ROOT $PYENV_ROOT

RUN pip install --upgrade pip \
 && pip install --no-cache-dir tox flake8 tox-pyenv black \
 && for pip in pip pip3.6 pip3.7 pip3.8 pip3.9 pip3.10; do \
      $pip install --upgrade pip \
      && $pip install --no-cache-dir pytest; \
    done \
 && pyenv global 3.10.4 3.9.13 3.8.13 3.7.13 3.6.15

CMD ["python"]
