FROM sawertyu/modern_python:3.6 as base-36
FROM sawertyu/modern_python:3.7 as base-37
FROM sawertyu/modern_python:3.8 as base-38
FROM sawertyu/modern_python:3.9 as base-all

COPY --from=base-36 $PYENV_ROOT/versions/ /tmp
COPY --from=base-37 $PYENV_ROOT/versions/ /tmp
COPY --from=base-38 $PYENV_ROOT/versions/ /tmp

RUN set -xe \
 && cp -r tmp/* $PYENV_ROOT/versions

FROM python:3-slim-buster

ENV PYENV_ROOT /.pyenv
ENV PATH $PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH

COPY --from=base-all $PYENV_ROOT $PYENV_ROOT

RUN pip install --upgrade pip \
 && pip install --no-cache-dir tox flake8 tox-pyenv pytest

CMD ["python"]
