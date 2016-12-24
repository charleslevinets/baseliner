#!/bin/bash
echo "" > ansible.log
ansible-playbook -e @vars.yml playbook.yml
