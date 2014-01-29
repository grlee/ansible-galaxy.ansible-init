# Ansible galaxy role to install ansible on Cygwin, Ubuntu, and Mac OS X 

This is a simple role that will try to install ansible on machines running Cygwin, Ubuntu, or Cygwin.
This plugin will use package managers (apt, brew, etc.) to do the heavy lifting.
Right now, the plugin uses a shell script to install ansible on a remote server.  (I imagine the shell script can be run directly on a local box that needs ansible.)
This is a rough first pass, so I expect changes as more platforms are tried out.

Currently, I've tested this plugin on:
- Cygwin
- Darwin (10.9.1)
- Ubuntu (14.04)

