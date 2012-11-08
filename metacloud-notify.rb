#!/usr/bin/env ruby

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

$: << File.expand_path("..", __FILE__) + '/lib'

# bundler integration and dependencies
require 'rubygems'
require 'bundler/setup'

require 'lumberjack'

require 'notifier'
require 'optparse_notifier'
require 'notifier_error'

options = OptparseNotifier.parse ARGV

case
  when options.log_to === :stdout
    logger = Lumberjack::Logger.new
  when options.log_to === :file
    logger = Lumberjack::Logger.new(options.log_to_file)
  when options.log_to === :stderr
    logger = Lumberjack::Logger.new(STDERR)
  else
    raise ArgumentError "Unknown logging device!"
end

logger.progname = 'MetaCloudNotifier'
logger.level = Lumberjack::Severity::DEBUG if options.debug

logger.info "Starting ..."

begin
  notifier = Notifier.new options, logger

  notifier.notify options.vm_state, options.vm_template
  logger.info "Notification successful"
rescue Exception => e
  logger.error "Notification unsuccessful. #{e.class.to_s}: #{e.message}"
  logger.debug "Error details: #{e.backtrace.to_s}"
  exit!(1)
end

logger.info "Shutting down ..."