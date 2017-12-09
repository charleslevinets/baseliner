#!/usr/bin/env bash
set -ex

PATH="$PATH:`pwd`/bin"

function launch_node {
  docker run -d --name=node$1 \
    -p 222$1:22 \
    -e ADD_INSECURE_KEY=true \
    -v /var/run/docker.sock:/var/run/docker.sock \
    ivotron/python-sshd:debian-9
}

function write_hosts_file {
  echo "" > hosts
  for i in `seq $1`; do
    echo "node$i ansible_host=localhost ansible_port=222$i ansible_user=root" >> hosts
  done
}

function run_examples_for_mode {
  for e in examples/$1/* ; do

    if [ ! -f $e/config.yml ]; then
      continue
    fi
    if [[ $e == *"compose_"* ]]; then
      # skip compose examples since they don't work with docker-in-docker yet
      continue
    fi

    pushd $e

    echo "###########################"
    echo " Running $1/`basename $e`"
    echo "###########################"
    echo ""

    docker run --rm --name=bliner \
      -v `pwd`:/bliner \
      -v $hostsfile:/hosts \
      -v $sshkey:/root/.ssh/id_rsa \
      --workdir=/bliner \
      --net=host \
      baseliner -e -s -i /hosts -m $1

    popd
  done
}

hostsfile=`pwd`/hosts
sshkey=`pwd`/ci/insecure_rsa

# single-node
launch_node 1
launch_node 2
write_hosts_file 1
run_examples_for_mode single-node

# parallel
launch_node 3
write_hosts_file 3
run_examples_for_mode parallel
