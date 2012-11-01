GLite LB scripts for OpenNebula v3.x
====================================

Description
-----------
GLite Logging and Bookkeeping (LB) scripts compatible with OpenNebula 3.4+.

Installation
------------
* Ruby 1.9.2+ (recommended)

~~~
rvm install 1.9.2 && rvm use 1.9.2 --default
~~~ 

* Bundler (required)

~~~
gem install bundler
~~~

* Scripts (required)

~~~
cd $ONE_LOCATION/var/remotes/hooks
git clone git://github.com/arax/metacloud-lb-scripts.git
~~~

* Gems (required)

~~~
cd $ONE_LOCATION/var/remotes/hooks/metacloud-lb-scripts
bundle install
~~~

* glite-lb client utilities (required for metalb service)

~~~
echo "deb http://scientific.zcu.cz/repos/META-RELEASE/debian/ stable/" >> /etc/apt/sources.list.d/glite.list
echo "deb http://scientific.zcu.cz/repos/EMI2-external/debian/ stable/" >> /etc/apt/sources.list.d/glite.list

apt-get update
apt-get install glite-lb-client-progs 
~~~

* globus-proxy client utilities (required for metalb service)

~~~
apt-get install globus-proxy-utils
~~~

* Valid credentials with an automatic renewal (e.g. a cron job with grid-proxy-init, required for metalb service)
* tail, grep, awk and tr utilities (required for metalb service)
* ENV variables (required for metalb service)

~~~
export GLITE_WMS_LOG_DESTINATION=HOSTNAME:PORT
export GLITE_LB_DESTINATION=HOSTNAME:PORT
~~~

* Hooks registered in OpenNebula's oned.conf (required)

Usage
-----
~~~
[PATH/]metacloud-notify.rb --vm-template BASE64_XML_TEMPLATE --vm-state HOOK_NAME --service-to-notify SERVICE [--debug] \
                           [--mapfile YAML_FILE] [--log-to DEVICE] [--log-to-file FILE] [--krb-realm MYREALM] [--krb-host-realm MYHOSTREALM]

SERVICE               := syslog | metalb
HOOK_NAME             := CREATE | PROLOG | RUNNING | SHUTDOWN | STOP | DONE | FAILED
YAML_FILE             := YAML file containing identity mappings (i.e. oneadmin: "xyzuser")
BASE64_XML_TEMPLATE   := Base64 encoded XML template
DEVICE                := Logger type [stdout|stderr|file], defaults to stdout
FILE                  := Log file, defaults to 'log/metacloud-notify.log'
MYREALM               := Krb5 realm for ON users
MYHOSTREALM           := Krb5 realm for ON VMs (principals host/HOSTNAME@MYHOSTREALM)
~~~

Examples
--------

Syslog (for testing purposes only)
~~~
VM_HOOK = [
   name      = "log_create",
   on        = "CREATE",
   command   = "metacloud-lb-scripts/metacloud-notify.rb",
   arguments = "--vm-state CREATE --vm-template $TEMPLATE --service-to-notify syslog" ]
~~~

Basic LB setup
~~~
VM_HOOK = [
   name      = "log_create",
   on        = "CREATE",
   command   = "metacloud-lb-scripts/metacloud-notify.rb",
   arguments = "--vm-state CREATE --vm-template $TEMPLATE --service-to-notify metalb" ]
~~~

Full LB setup (with debug mode)
~~~
VM_HOOK = [
   name      = "log_create",
   on        = "CREATE",
   command   = "metacloud-lb-scripts/metacloud-notify.rb",
   arguments = "--vm-template $TEMPLATE --vm-state create --service-to-notify metalb --mapfile /opt/opennebula/etc/metacloud-notify.mapfile --log-to file --log-to-file /opt/opennebula/var/metacloud-notify.log --debug --krb-realm META" ]

VM_HOOK = [
   name      = "log_prolog",
   on        = "PROLOG",
   command   = "metacloud-lb-scripts/metacloud-notify.rb",
   arguments = "--vm-template $TEMPLATE --vm-state prolog --service-to-notify metalb --mapfile /opt/opennebula/etc/metacloud-notify.mapfile --log-to file --log-to-file /opt/opennebula/var/metacloud-notify.log --debug --krb-realm META" ]

VM_HOOK = [
   name      = "log_running",
   on        = "RUNNING",
   command   = "metacloud-lb-scripts/metacloud-notify.rb",
   arguments = "--vm-template $TEMPLATE --vm-state running --service-to-notify metalb --mapfile /opt/opennebula/etc/metacloud-notify.mapfile --log-to file --log-to-file /opt/opennebula/var/metacloud-notify.log --debug --krb-realm META" ]

VM_HOOK = [
   name      = "log_shutdown",
   on        = "SHUTDOWN",
   command   = "metacloud-lb-scripts/metacloud-notify.rb",
   arguments = "--vm-template $TEMPLATE --vm-state shutdown --service-to-notify metalb --mapfile /opt/opennebula/etc/metacloud-notify.mapfile --log-to file --log-to-file /opt/opennebula/var/metacloud-notify.log --debug --krb-realm META" ]

VM_HOOK = [
   name      = "log_stop",
   on        = "STOP",
   command   = "metacloud-lb-scripts/metacloud-notify.rb",
   arguments = "--vm-template $TEMPLATE --vm-state stop --service-to-notify metalb --mapfile /opt/opennebula/etc/metacloud-notify.mapfile --log-to file --log-to-file /opt/opennebula/var/metacloud-notify.log --debug --krb-realm META" ]

VM_HOOK = [
   name      = "log_done",
   on        = "DONE",
   command   = "metacloud-lb-scripts/metacloud-notify.rb",
   arguments = "--vm-template $TEMPLATE --vm-state done --service-to-notify metalb --mapfile /opt/opennebula/etc/metacloud-notify.mapfile --log-to file --log-to-file /opt/opennebula/var/metacloud-notify.log --debug --krb-realm META" ]

VM_HOOK = [
   name      = "log_failed",
   on        = "FAILED",
   command   = "metacloud-lb-scripts/metacloud-notify.rb",
   arguments = "--vm-template $TEMPLATE --vm-state failed --service-to-notify metalb --mapfile /opt/opennebula/etc/metacloud-notify.mapfile --log-to file --log-to-file /opt/opennebula/var/metacloud-notify.log --debug --krb-realm META" ]
~~~