#!/bin/bash
set -e -x

# delete previous results
sudo rm -f results/runtime_*
sudo rm -fr results/machine/*

docker run --rm -ti \
  -v `pwd`:/experiment \
  -v `pwd`/../:/experiment/roles/baseliner \
  -v `pwd`/results:/results \
  -v $HOME/.ssh/id_rsa:/root/.ssh/id_rsa \
  --workdir=/experiment \
  --net=host \
  --entrypoint=/bin/bash \
  ivotron/ansible:2.2.0.0 -c \
    "ansible-playbook -e @vars.yml playbook.yml"
