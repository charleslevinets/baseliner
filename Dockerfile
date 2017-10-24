FROM ivotron/ansible:2.4.0.0-alpine3

ADD . /etc/ansible/roles/baseliner

ENTRYPOINT ["/etc/ansible/roles/baseliner/bin/baseliner"]
