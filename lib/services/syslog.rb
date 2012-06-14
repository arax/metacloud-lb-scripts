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

  def initialize(notifier_name = "OpenNebulaSyslogNotifier")

    @syslog = Lumberjack::Logger.new(Lumberjack::SyslogDevice.new({:facility => Syslog::LOG_SYSLOG}))
    @syslog.progname = notifier_name

  end

  def write(message)

    @syslog.info message

  end

  def prepare_message(vm_state, user_identity, vm_template)

    msg_template = ERB.new File.new(File.expand_path("..", __FILE__) + "/templates/syslog.erb").read
    msg_template.result(binding)

  end

end
