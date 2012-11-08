# -------------------------------------------------------------------------- #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License. You may obtain    #
# a copy of the License at                                                   #
#                                                                            #
# http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
#--------------------------------------------------------------------------- #

require 'lumberjack_syslog_device'
require 'syslog'
require 'erb'

class SyslogService

  attr_reader :logger
  attr_reader :notifier_name

  def initialize(notifier_name, logger)

    @notifier_name = notifier_name || "OpenNebulaSyslogNotifier"

    @logger = logger

    @syslog = Lumberjack::Logger.new(Lumberjack::SyslogDevice.new({:facility => Syslog::LOG_SYSLOG}))
    @syslog.progname = notifier_name

  end

  def write(message)

    @logger.debug "[#{@notifier_name}] writting:\n#{message}" unless @logger.nil?
    @syslog.info message

  end

  def prepare_message(vm_state, user_identity, vm_template, additional = {})

    krb_host_realm = additional[:krb_host_realm]
    vm_usage = additional[:vm_usage]

    msg_template = ERB.new File.new(File.expand_path("..", __FILE__) + "/templates/syslog.erb").read
    message = msg_template.result(binding)

    @logger.debug "[#{@notifier_name}] constructed:\n#{message}" unless @logger.nil?

    message

  end

end
