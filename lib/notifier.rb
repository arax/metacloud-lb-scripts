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
require 'chronic_duration'

require 'vm_template'
require 'notifier_error'

require_all File.expand_path("..", __FILE__) + '/services/'

class Notifier

  def initialize(service, logger, mapfile = nil)

    logger.info "Initializing notifier for #{service.to_s.capitalize}"

    @logger = logger
    @mapfile = YAML.load(mapfile) unless mapfile.nil? or mapfile.empty?

    classname = service.to_s.capitalize + 'Service'
    @service = Kernel.const_get(classname).new nil, logger

  end

  def notify(vm_state, vm_template)

    raise ArgumentError, "VM template should not be empty!" if vm_template.nil? or vm_template.empty?
    raise ArgumentError, "VM state should not be empty!" if vm_state.nil?
    @logger.info "Sending a message to #{@service.class.name}"


    begin

      vm_template_xml = decode_base64 vm_template
      vm_info = read_template vm_template_xml

      vm_user = map_user_identity vm_info.UNAME

      vm_usage = prepare_usage vm_state, vm_info

      vm_notification = prepare_notification vm_state, vm_user, vm_info, vm_usage

    rescue Exception => e

      @logger.error "Notifier failed to prepare the notification message. Error: #{e.message}"
      @logger.debug "Error details: #{e.backtrace.inspect}"
      raise NotifierError, "#{e.message}"

    end

    @service.write vm_notification

  end

  def map_user_identity(user_name)

    raise ArgumentError, "Username should not be empty!" if user_name.nil? or user_name.empty?
    @logger.info "Looking for global identity of user #{user_name}"

    identity = user_name
    identity = @mapfile[user_name] unless @mapfile.nil? or not @mapfile.has_key? user_name

    @logger.debug "Found mapping #{user_name} => #{identity}"
    identity

  end

  def prepare_notification(vm_state, user_identity, vm_template, vm_usage)

    raise ArgumentError, "VM state, user identity and VM template should not be empty!" if vm_template.nil? or vm_state.nil? or user_identity.nil? or user_identity.empty? or vm_usage.nil?
    raise ArgumentError, "Invalid VMTemplate!" if vm_template.class != VMTemplate
    @logger.info "Constructing #{vm_state.to_s.upcase} notification message for #{vm_template.NAME} which will be sent to #{@service.class.name}"

    notification = @service.prepare_message vm_state, user_identity, vm_template, vm_usage

    @logger.debug "Notification message will contain the following: #{notification}"
    notification

  end

  def prepare_usage(vm_state, vm_template)

    raise ArgumentError, "VM template and VM state should not be empty!" if vm_template.nil? or vm_state.nil?
    raise ArgumentError, "Invalid VMTemplate!" if vm_template.class != VMTemplate
    @logger.info "Computing usage for #{vm_template.ID}"

    # reset usage for states other than DONE
    return "VM is still running" if vm_state != :done

    seq_num = 0
    seq_num = vm_template.START_TIME.length unless vm_template.START_TIME.nil?

    return "Usage record is malformed!" if seq_num == 0 or vm_template.END_TIME.length != seq_num

    @logger.debug "#{vm_template.ID} has #{seq_num} usage records"
    seq_num = seq_num - 1
    sum = 0

    (0..seq_num).each do |index|
      runtime = vm_template.END_TIME[index] - vm_template.START_TIME[index]

      @logger.debug "#{vm_template.ID} has been running #{ChronicDuration::output(runtime, :format => :short)} in seq ##{index}"
      sum = sum + runtime unless runtime < 0
    end

    usage = ChronicDuration::output(sum, :format => :short)

    @logger.debug "#{vm_template.ID} has been running #{usage}"

    usage

  end

  def decode_base64(encoded_string)

    raise ArgumentError, "Base64 encoded string should not be nil!" if encoded_string.nil?
    @logger.info "Decoding Base64"

    decoded_string = Base64.decode64 encoded_string

    @logger.debug "BASE64: #{encoded_string}\n XML: #{decoded_string}"
    decoded_string

  end

  def read_template(vm_template_xml)

    raise ArgumentError, "XML template should not be empty!" if vm_template_xml.nil? or vm_template_xml.empty?
    @logger.info "Parsing XML template"
    vm_template = VMTemplate.parse vm_template_xml, :single => true

    @logger.debug "Parsed data structure for VM with ID: #{vm_template.ID.to_s}"
    vm_template

  end

end
