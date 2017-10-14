# baseliner

Ansible role to obtain performance baselines on remote machines.

## Variables

This role expects certain variables to be defined:

  * `benchmarks`. A list of benchmarks to execute (one benchmark per 
    item). At least one element must be defined. For each, the 
    expected variables depend on the method being used to execute the 
    benchmark on the remote machine:
      * Docker. If using Docker at least the `image` variable is 
        expected, which points to the docker image to execute. Other 
        optional variables are `network_mode`, `command`, `ipc`, 
        `privileged`, `volumes`, `cgroup_parent`, `environment` and 
        `cap_add`. The semantics of these variables is the same as 
        specified by the [docker compose]() YAML spec.
      * Compose. If using docker compose a `compose` variable is 
        expected, containing a compose-compatible specification. Note 
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

## Examples

More examples are available in the `examples/` folder.

## CLI command

A wrapper for making use of the role. First, write a configuration 
(YAML) file containing the variables described above in a `config.yml` 
file:

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

Then write a `hosts` file containing the inventory. And then:

```bash
cd baseliner/
bin/baseliner
```

### In Docker

The role is conveniently packaged in a docker image, [available from 
Docker's hub](https://hub.docker.com/r/ivotron/baseliner/). We 
currently only keep the latest version available.

