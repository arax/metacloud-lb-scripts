LB scripts for OpenNebula v3.x
==============================

Description
-----------
Logging and Bookkeeping (LB) scripts compatible with OpenNebula's VM_HOOKs.

Installation
------------
* Ruby 1.9.2+ => 'rvm install 1.9.2 && rvm use 1.9.2 --default'
* Bundler => 'gem install bundler'
* Gems => 'bundle install'
* Working glite-lb-* client utilities with custom OpenNebula support (not included)
* Working tail, grep, awk and tr utilities

Usage
-----
~~~
[PATH]/metacloud-notify.rb --vm-template BASE64_XML_TEMPLATE --vm-state HOOK_NAME --service-to-notify SERVICE [--debug] [--mapfile YAML_FILE]

SERVICE := syslog | metalb
HOOK_NAME := CREATE | PROLOG | RUNNING | SHUTDOWN | STOP | DONE | FAILED
YAML_FILE := YAML file containing identity mappings (i.e. oneadmin: "xyzuser")
BASE64_XML_TEMPLATE := Base64 encoded XML template
~~~

Examples
--------
~~~
VM_HOOK = [
   name      = "log_create",
   on        = "CREATE",
   command   = "/opt/opennebula/bin/metacloud-notify.rb",
   arguments = "--vm-state CREATE --vm-template $TEMPLATE --service-to-notify syslog" ]

VM_HOOK = [
   name      = "log_create",
   on        = "CREATE",
   command   = "/opt/opennebula/bin/metacloud-notify.rb",
   arguments = "--vm-state CREATE --vm-template $TEMPLATE --service-to-notify metalb" ]
~~~
