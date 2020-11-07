FROM sawertyu/modern_python:3.6 as base-36
FROM sawertyu/modern_python:3.7 as base-37
FROM sawertyu/modern_python:3.9 as base-all

COPY --from=base-36 $PYENV_ROOT/versions/ /tmp
COPY --from=base-37 $PYENV_ROOT/versions/ /tmp

RUN set -xe \
 && cp -r tmp/* $PYENV_ROOT/versions \
 && rm -rf $PYENV_ROOT/.git \
 && rm -rf $PYENV_ROOT/plugins/python-build \
 && rm -rf $PYENV_ROOT/*.log

FROM python:3-slim-buster

ENV PYENV_ROOT /.pyenv
ENV PATH $PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH

COPY --from=base-all $PYENV_ROOT $PYENV_ROOT

RUN pip install --upgrade pip \
 && pip install tox flake8 tox-pyenv pytest

CMD ["python"]
