LB scripts for OpenNebula v3.4
==============================

Description
-----------
Logging and Bookkeeping (LB) scripts compatible with OpenNebula's VM_HOOKs.

Usage
-----
[PATH]/metacloud-notify.rb --vm-template BASE64_XML_TEMPLATE --vm-state HOOK_NAME --service-to-notify SERVICE [--debug]

SERVICE := syslog | metalb
HOOK_NAME := CREATE | PROLOG | RUNNING | SHUTDOWN | STOP | DONE | FAILED

Examples
--------
VM_HOOK = [
   name      = "log_create",
   on        = "CREATE",
   command   = "/opt/opennebula/bin/metacloud-notify.rb",
   arguments = "--vm-state CREATE --vm-template $TEMPLATE --service-to-notify syslog" ]
