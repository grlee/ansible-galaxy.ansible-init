# Ansible galaxy role to install ansible on Cygwin, Ubuntu, and Mac OS X 

This is a simple role that will try to install ansible on machines running Cygwin, Ubuntu, or Cygwin.
This plugin will use package managers (apt, brew, etc.) to do the heavy lifting.
Right now, the plugin uses a shell script to install ansible on a remote server.  (I imagine the shell script can be run directly on a local box that needs ansible.)

Currently, I've tested this plugin on:
- Cygwin
- Darwin (10.9.1)
- Ubuntu (14.04)

The shell script that underlies this role can be called directly to install ansible.  Combined with wget, this can be invoked as a one-liner:

wget -O - https://raw.githubusercontent.com/grlee/ansible-galaxy.ansible-init/develop/files/setup.sh | bash

This one-liner will generate batch files for windows to run ansible from the windows command line:

ls -1 /usr/bin/ansible* | sed 's|/usr/bin/||g' | grep -v \.bat | xargs -ifoo echo echo \'%CYGWIN_HOME%\\bin\\bash -c "foo %*"\' \> /usr/local/bin/foo.bat | bash


