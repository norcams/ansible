#!/usr/bin/env python
""" Remove SSH known hosts """

import os
import sys
import ConfigParser
import argparse
from subprocess import call

desc = 'Remove SSH known hosts'
parser = argparse.ArgumentParser(description=desc)
parser.add_argument('hosts',
                    metavar='hosts',
                    type=str,
                    help='ansible host or group')
options = parser.parse_args()
hosts = options.hosts.split('-')
loc = role = hostid = None
if len(hosts) > 0:
    loc = hosts[0]
if len(hosts) > 1:
    role = hosts[1]
if len(hosts) > 2:
    hostid = hosts[2]

dir_path = os.path.dirname(os.path.realpath(__file__))
configfile = '%s/../inventory/%s' % (dir_path, loc)
if not os.path.isfile(configfile):
    print "could not find ansible inventory for %s" % loc
    print configfile
    sys.exit(1)

inventory = ConfigParser.ConfigParser(allow_no_value=True)
inventory.read(configfile)

if not role:
    section = '%s:children' % loc
elif not hostid:
    section = '%s-%s' % (loc, role)
else:
    section = None
    host = ['%s-%s-%s' % (loc, role, hostid)]
if section:
    if 'children' in section:
        children = inventory.options(section)
        host = []
        for c in children:
            host += inventory.options(c)
    else:
        host = inventory.options(section)


for h in host:
    print "Run for host [%s]" % h
    command = 'sudo ansible-playbook -e "myhosts=%s-login host=%s" \
        %s/../lib/ssh_host_keys.yaml' % (loc, h, dir_path)
    os.system(command)
