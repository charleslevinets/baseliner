FROM ivotron/ansible:2.2.1.0

ADD . /etc/ansible/roles/baseliner

ENTRYPOINT ["/etc/ansible/roles/baseliner/bin/baseliner"]
