# Ansible managment of himlar

Based on usage in [himlar](https://github.com/norcams/himlar) and with
[himlarcli](https://github.com/norcams/himlarcli)

# Inventory

Inventory files can be updated from foreman with `$himlarcli/ansible_hosts.py`

# Variables
Default values are in `group_vars/all.yaml` and can then be overridden in
`group_vars/$loc.yaml` or `group_vars/$loc-$role.yaml` (or in `host_vars/`
as a last resort).

# Run
Always run with sudo and with hosts variable set on the command line.
All playbook should be stored under lib/ and hosts can be single hostname,
`$loc` or `$loc-$role`. 

Example:
```bash
sudo ansible-playbook -e "hosts=bgo" lib/ping.yaml
```
# Dry-run

To use dry-run add `--check` to the command

