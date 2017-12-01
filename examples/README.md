# Examples

To run examples, create a `hosts` file in [Ansible's inventory 
format](http://docs.ansible.com/ansible/latest/intro_inventory.html) 
and then invoke baseliner. For example:

```bash
$> cd examples/single-node/compose_redis

# create a hosts file

$> echo 'node1.example.domain.org' > hosts
$> echo 'node2.example.domain.org' >> hosts
$> echo 'node3.example.domain.org' >> hosts

# invoke baseliner
baseliner
```
