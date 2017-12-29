#!/usr/bin/env bash
set -ex

PATH="$PATH:`pwd`/bin"

function launch_node {
  docker run -d --name=node$1 \
    -p 222$1:22 \
    -e ADD_INSECURE_KEY=true \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /tmp:/tmp \
    ivotron/python-sshd:debian-9
}

function write_hosts_file {
  echo "" > hosts
  for i in `seq $1`; do
    echo "node$i ansible_host=localhost ansible_port=222$i ansible_user=root" >> hosts
  done
}

function run_test {
  mode=$1
  t=$2

  pushd examples/$mode/$t

  docker run --rm --name=bliner \
    -v `pwd`:/bliner \
    -v $hostsfile:/hosts \
    -v $sshkey:/root/.ssh/id_rsa \
    --workdir=/bliner \
    --net=host \
    baseliner -e -s -i /hosts -m $mode -d 60

  popd
}

docker build -t baseliner .
curl -O https://raw.githubusercontent.com/ivotron/docker-openssh/master/insecure_rsa
chmod 600 insecure_rsa
mv insecure_rsa ci/

sshkey=`pwd`/ci/insecure_rsa
hostsfile=`pwd`/hosts

# single-node 1 node
launch_node 1
write_hosts_file 1
run_test single-node docker_fetch_output compose_redis

# single-node and parallel modes with 3 nodes
launch_node 2
launch_node 3
write_hosts_file 3
run_test single-node docker_fetch_output
run_test single-node docker_parameter_sweep
run_test single-node docker_custom_entrypoint
run_test parallel docker_parallelmode
