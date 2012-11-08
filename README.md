GLite LB scripts for OpenNebula v3.4+
=====================================

Description
-----------
GLite Logging and Bookkeeping (LB) scripts compatible with OpenNebula 3.4+.

Installation
------------
* Ruby 1.9.2+ (recommended)

If your distro doesn't provide packages for newer Ruby versions, you can
use [RVM](https://rvm.io/rvm/install/). 
~~~
rvm install 1.9.2 && rvm use 1.9.2 --default
~~~ 

* Bundler (required)

Bundler will help you with dependencies later on.
~~~
gem install bundler
~~~

* Scripts (required)

OpenNebula looks for custom hooks in a specific location, but you can always
choose your own directory and specify full path to the hook later.

NOTICE: OpenNebula's remote scripts can be propagated to hosts using
the "onehost sync" command. This has been know to fail when "remotes/hooks"
contains the ".git" directory. If you experience problems, move ".git"
to a different directory (do NOT remove it, it's useful to have a git-enabled
installation during updates).
~~~
cd $ONE_LOCATION/var/remotes/hooks
git clone git://github.com/arax/metacloud-lb-scripts.git
~~~

* Gems (required)

All dependencies are handled by Bundler, but some gems might have their own
non-Ruby dependencies (usually a few *-dev packages you have to install by
hand, e.g. libexpat-dev for nokogiri XML parser etc.). If there are missing
dependencies for native extensions, install them and re-run Bundler.
~~~
cd $ONE_LOCATION/var/remotes/hooks/metacloud-lb-scripts
bundle install
~~~

* glite-lb client utilities (required for metalb service)

LB notification are sent using native binaries "glite-lb-job_reg" and
"glite-lb-logevent". You can install them as a part of "glite-lb-client-progs"
from Debian/Ubuntu repos mentioned below.

NOTICE: Don't forget to update PATH, "glite-lb-logevent" is often
installed in "/usr/lib/glite-lb/examples".
~~~
echo "deb http://scientific.zcu.cz/repos/META-RELEASE/debian/ stable/" >> /etc/apt/sources.list.d/glite.list
echo "deb http://scientific.zcu.cz/repos/EMI2-external/debian/ stable/" >> /etc/apt/sources.list.d/glite.list
~~~
~~~
apt-get update
apt-get install glite-lb-client-progs 
~~~

* globus-proxy client utilities (required for metalb service)

You should choose an auth mechanism based on your LB server capabilities.
This example will use X.509 proxy certificates.
~~~
apt-get install globus-proxy-utils
~~~

* Valid credentials with an automatic renewal (e.g. a cron job with grid-proxy-init, required for metalb service)

The script doesn't check your credentials, you shouldn't let them expire!
~~~
*/15 * * * * grid-proxy-init
~~~

* ENV variables (required for metalb service)

Destination for events is determined from ENV variables, HOSTNAME should
be a FQDN (no protocol, no slashes).
~~~
export GLITE_WMS_LOG_DESTINATION=<HOSTNAME>:<PORT>
export GLITE_LB_DESTINATION=<HOSTNAME>:<PORT>
~~~

* Hooks registered in OpenNebula's oned.conf (required)

See [Examples](#Examples) below.

Usage
-----
You can use the script directly from shell. This is useful for testing.
Sample BASE64_XML_TEMPLATEs are available in "test/mockdata/base64".
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
Shell (you can go through CREATE -> PROLOG -> RUNNING -> SHUTDOWN -> DONE)
~~~
./metacloud-notify.rb --vm-state CREATE --vm-template `cat test/mockdata/base64/CREATE.460` --service-to-notify metalb --debug --mapfile test/mockdata/mapfile
~~~

Hook for Syslog (testing purposes only)
~~~
VM_HOOK = [
   name      = "log_create",
   on        = "CREATE",
   command   = "metacloud-lb-scripts/metacloud-notify.rb",
   arguments = "--vm-state CREATE --vm-template $TEMPLATE --service-to-notify syslog" ]
~~~

Hook for basic LB setup
~~~
VM_HOOK = [
   name      = "log_create",
   on        = "CREATE",
   command   = "metacloud-lb-scripts/metacloud-notify.rb",
   arguments = "--vm-state CREATE --vm-template $TEMPLATE --service-to-notify metalb" ]
~~~

Hooks for full LB setup (with debug mode)
~~~
VM_HOOK = [
   name      = "log_create",
   on        = "CREATE",
   command   = "metacloud-lb-scripts/metacloud-notify.rb",
   arguments = "--vm-template $TEMPLATE --vm-state create --service-to-notify metalb --mapfile /opt/opennebula/etc/metacloud-notify.mapfile --log-to file --log-to-file /opt/opennebula/var/metacloud-notify.log --debug --krb-realm USERS.EXAMPLE.COM --krb-host-realm VMS.EXAMPLE.COM" ]

VM_HOOK = [
   name      = "log_prolog",
   on        = "PROLOG",
   command   = "metacloud-lb-scripts/metacloud-notify.rb",
   arguments = "--vm-template $TEMPLATE --vm-state prolog --service-to-notify metalb --mapfile /opt/opennebula/etc/metacloud-notify.mapfile --log-to file --log-to-file /opt/opennebula/var/metacloud-notify.log --debug --krb-realm USERS.EXAMPLE.COM --krb-host-realm VMS.EXAMPLE.COM" ]

VM_HOOK = [
   name      = "log_running",
   on        = "RUNNING",
   command   = "metacloud-lb-scripts/metacloud-notify.rb",
   arguments = "--vm-template $TEMPLATE --vm-state running --service-to-notify metalb --mapfile /opt/opennebula/etc/metacloud-notify.mapfile --log-to file --log-to-file /opt/opennebula/var/metacloud-notify.log --debug --krb-realm USERS.EXAMPLE.COM --krb-host-realm VMS.EXAMPLE.COM" ]

VM_HOOK = [
   name      = "log_shutdown",
   on        = "SHUTDOWN",
   command   = "metacloud-lb-scripts/metacloud-notify.rb",
   arguments = "--vm-template $TEMPLATE --vm-state shutdown --service-to-notify metalb --mapfile /opt/opennebula/etc/metacloud-notify.mapfile --log-to file --log-to-file /opt/opennebula/var/metacloud-notify.log --debug --krb-realm USERS.EXAMPLE.COM --krb-host-realm VMS.EXAMPLE.COM" ]

VM_HOOK = [
   name      = "log_stop",
   on        = "STOP",
   command   = "metacloud-lb-scripts/metacloud-notify.rb",
   arguments = "--vm-template $TEMPLATE --vm-state stop --service-to-notify metalb --mapfile /opt/opennebula/etc/metacloud-notify.mapfile --log-to file --log-to-file /opt/opennebula/var/metacloud-notify.log --debug --krb-realm USERS.EXAMPLE.COM --krb-host-realm VMS.EXAMPLE.COM" ]

VM_HOOK = [
   name      = "log_done",
   on        = "DONE",
   command   = "metacloud-lb-scripts/metacloud-notify.rb",
   arguments = "--vm-template $TEMPLATE --vm-state done --service-to-notify metalb --mapfile /opt/opennebula/etc/metacloud-notify.mapfile --log-to file --log-to-file /opt/opennebula/var/metacloud-notify.log --debug --krb-realm USERS.EXAMPLE.COM --krb-host-realm VMS.EXAMPLE.COM" ]

VM_HOOK = [
   name      = "log_failed",
   on        = "FAILED",
   command   = "metacloud-lb-scripts/metacloud-notify.rb",
   arguments = "--vm-template $TEMPLATE --vm-state failed --service-to-notify metalb --mapfile /opt/opennebula/etc/metacloud-notify.mapfile --log-to file --log-to-file /opt/opennebula/var/metacloud-notify.log --debug --krb-realm USERS.EXAMPLE.COM --krb-host-realm VMS.EXAMPLE.COM" ]
~~~
