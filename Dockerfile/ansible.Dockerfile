FROM python:3.9-alpine as build

COPY requirements.txt .

RUN apk add --no-cache \
    make \
    sshpass \
    openssh \
    gcc \
    g++ \
    libffi-dev \
    openssl \
    openssl-dev \
    && rm -vrf /var/cache/apk/* \
    && pip install --upgrade pip wheel setuptools \
    && pip install -r requirements.txt

FROM python:3.9-alpine as ansible

COPY --from=build /usr/local/bin/ansible /usr/local/bin/ansible
COPY --from=build /usr/local/bin/ansible-playbook /usr/local/bin/ansible-playbook
COPY --from=build /usr/local/bin/ansible-playbook /usr/local/bin/ansible-galaxy
COPY --from=build /usr/local/bin/ansible-playbook /usr/local/bin/ansible-vault
COPY --from=build /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages

RUN adduser --disabled-password --gecos "" ansible \
    && apk add --no-cache sshpass openssh \
    && rm -vrf /var/cache/apk/*

USER ansible

ENTRYPOINT [ "sh" ]