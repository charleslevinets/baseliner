<img src="docs/baseliner.png" width="400px">

----------

[![Build Status](https://travis-ci.org/ivotron/baseliner.svg?branch=master)](https://travis-ci.org/ivotron/baseliner)

Obtain performance baselines on a cluster of machines. Only SSH and 
Python is required on the hosts (baseliner is implemented using 
[Ansible](https://ansible.com)). A slideshow with an overview can be found [here](https://docs.google.com/presentation/d/1zajJraXS_oQp1W1rbOe3TU07lcjCQRGKGQWGpL_boJs).

## Usage

```
Usage: baseliner [-i inventory] [-o dir] [-f <conf>] [-m mode] [-e]

Flags:
  -i <inventory> inventory file passed to ansible (default: ./hosts).
  -f <conf>      baseliner configuration file (default: ./config.yml).
  -o <out-dir>   output directory (default: ./results).
  -m <mode>      one of 'single-node' or 'parallel' (default: single-node).
  -e             terminate execution on first failure (default: false).
```

## Example

 1. Write a configuration (YAML) file containing the variables 
    described above in a `config.yml` file:

    ```
    repetitions: 1
    remote_results_path: "/tmp/results"
    enable_monitoring: true
    leave_monitor_running: false
    test_timeout: 2400

    benchmarks:
    - name: zlog
      image: ivotron/zlog-kv:79782a3
      command: 100000
      cgroup_parent: /
    ```

 2. Write a `hosts` file containing the list of hosts. For example:

    ```
    node1.example.domain.org
    node2.example.domain.org
    node3.example.domain.org
    ```


Then, in the folder where these two files are located, invoke the 
`baseliner` command. Alternatively, use `-f` and `-i` flags to specify 
different file names and locations:

```bash
baseliner -f /path/to/configuration.yml -i /path/to/machines_file
```

Results are placed in a `results` folder. More examples are available 
in the [`examples/`](examples/) folder.

## Configuration File Syntax

Baseliner expects certain variables to be defined in a `config.yml` file:

  * `benchmarks`. A list of benchmarks to execute (one benchmark per 
    item). At least one element must be defined. For each, the 
    expected variables depend on the method being used to execute the 
    benchmark on the remote machine:
      * Docker. If using Docker at least the `image` variable is 
        expected, which points to the docker image to execute. Other 
        optional variables are `network_mode`, `command`, `ipc`, 
        `privileged`, `volumes`, `cgroup_parent`, `environment` and 
        `cap_add`. The semantics of these variables is the same as 
        specified by the [docker 
        compose](https://docs.docker.com/compose/compose-file/) YAML 
        spec.
      * Compose. If using docker compose a `compose` variable is 
        expected, containing an specification in [compose YAML 
        format](https://docs.docker.com/compose/compose-file/). Note 
        that compose itself its executed in a docker container (i.e. 
        is not installed on the host).
      * Script. If a custom script is used, the `script` variable is 
        expected. The script is copied to the host's `$HOME` and 
        invoked there.

    Other variables common to all methods are:

      * `put`. A list of dictionaries containing `src` and `dest` 
        elements specifying files to transfer from the localhost 
        (where baseliner runs) to eahc of the hosts in the inventory 
        file.
      * `fetch`. List of files (or paths) to retrieve. The files are 
        placed in the folder pointed by `local_results_folder`.
      * `parameters`. A dictionary of lists, each describing a 
        parameter to use for a test. The role takes the cartesian 
        product of all the parameters and executes all combinations.
      * `environment_host`. A dictionary used to specify environment 
        variables for a particular host. The keys should correspond to 
        `{{ ansible_hostname }}` values.

  * `repetitions`. The number of times that each test is executed. 
    (default: 1).
  * `local_results_folder`. Folder where to place results obtained 
    from the execution of containers (default: `./`).
  * `remote_results_folder`. Where to store results on the remote 
    hosts. This folder gets created if it doesn't exist. If it exists, 
    its contents are deleted as part of the execution of this role 
    (default: `/tmp/results`).
  * `enable_monitoring`. Whether to enable monitoring on the hosts. 
    This requires Docker on the machine where the role is executed. 
    The monitoring setup is the one described 
    [here](https://stefanprodan.com/2016/a-monitoring-solution-for-docker-hosts-containers-and-containerized-services).
  * `test_timeout`. Timeout for tests in seconds (default: 10800 
    seconds).

## Installation

### Docker

The role is conveniently packaged in a docker image, [available from 
Docker's hub](https://hub.docker.com/r/ivotron/baseliner/).

### PIP

Coming soon ([#32](https://github.com/ivotron/baseliner/issues/32))
