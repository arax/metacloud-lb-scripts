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

$: << File.expand_path("..", __FILE__) + '/../lib'

# bundler integration and dependencies
require 'rubygems'
require 'bundler/setup'

require 'notifier'
require 'vm_template'
require 'nokogiri'
require "test/unit"

class DummyLogger
  def debug message
    #
  end

  def info message
    #
  end

  def error message
    #
  end
end

class NotifierTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Fake logger
    @logger = DummyLogger.new

    # Test data
    @data64_wrong = File.open(File.expand_path("..", __FILE__) + '/mockdata/vm.one.base64_wrong', "r").read
    @data64 = File.open(File.expand_path("..", __FILE__) + '/mockdata/vm.one.base64', "r").read
    @data_wrong = File.open(File.expand_path("..", __FILE__) + '/mockdata/vm.one_wrong', "r").read
    @data = File.open(File.expand_path("..", __FILE__) + '/mockdata/vm.one', "r").read

    # Notifier instance
    @notifier = Notifier.new(:syslog, @logger)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown
    # Do nothing
  end

  def test_decode_base64

    assert_equal(@data, @notifier.decode_base64(@data64), "Encoded and decoded data should match!")
    assert_not_equal(@data, @notifier.decode_base64(@data64_wrong), "Random and decoded data should not match!")
    assert_empty(@notifier.decode_base64(""))

  end

  def test_read_template

    assert_instance_of(VMTemplate, @notifier.read_template(@data))
    assert_raise Nokogiri::XML::SyntaxError do
      @notifier.read_template(@data_wrong)
    end
    assert_equal(439, @notifier.read_template(@data).ID)

  end

  def test_map_user_identity
    assert_equal("oneadmin", @notifier.map_user_identity("oneadmin"))
  end

  def test_prepare_notification
    assert_raise ArgumentError do
      @notifier.prepare_notification(:create, "oneadmin", nil)
    end
  end
end
