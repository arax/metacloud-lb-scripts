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

  def initialize(service, logger)

    logger.debug "Initializing notifier for " + service.to_s.capitalize

    classname = service.to_s.capitalize + 'Service'
    @service = Kernel.const_get(classname).new
    @logger = logger

  end

  def notify(message)

    @logger.debug "Sending a message to " + @service.class.name 
    @service.write message
 
  end

  def decode_base64(encoded_string)

    @logger.debug "Decoding BASE64: \n" + encoded_string
    Base64.decode64 encoded_string

  end

  def read_template(vm_template)

    @logger.debug "Parsing XML template: \n" + vm_template
    vm_template = VMTemplate.parse(vm_template, :single => true)

    @logger.debug "Parsed data structure for VM with ID: " + vm_template.ID.to_s
    vm_template

  end

end
