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

require 'require_all'
require 'base64'

require 'vm_template'

require_all File.expand_path("..", __FILE__) + '/services/'

class Notifier

  def initialize(service, logger, mapfile = nil)

    logger.debug "Initializing notifier for " + service.to_s.capitalize

    classname = service.to_s.capitalize + 'Service'
    @service = Kernel.const_get(classname).new
    @logger = logger
    @mapfile = YAML.load(File.read(mapfile)) unless mapfile.nil?

  end

  def notify(message)

    @logger.debug "Sending a message to " + @service.class.name
    @service.write message
 
  end

  def map_user_identity(user_name)

    @logger.debug "Looking for global identity of user " + user_name
    unless @mapfile.nil? or @mapfile.has_key? user_name
      @mapfile[user_name] 
    else
      user_name
    end

  end

  def prepare_notification(vm_state, user_identity, vm_template)

    raise ArgumentError, "VM should not be empty!" if vm_template.nil?
    @logger.debug "Constructing " + vm_state.to_s.upcase + " notification message for " + vm_template.NAME + " which will be sent to " + @service.class.name

    @service.prepare_message vm_state, user_identity, vm_template

  end

  def decode_base64(encoded_string)

    @logger.debug "Decoding BASE64: \n" + encoded_string
    Base64.decode64 encoded_string

  end

  def read_template(vm_template_xml)

    @logger.debug "Parsing XML template: \n" + vm_template_xml
    vm_template = VMTemplate.parse vm_template_xml, :single => true

    @logger.debug "Parsed data structure for VM with ID: " + vm_template.ID.to_s
    vm_template

  end

end
