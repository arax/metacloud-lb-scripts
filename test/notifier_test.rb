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

    @data64 = {}
    @data = {}
    @data_wrong = {}

    # Test data
    Dir.glob(File.expand_path("..", __FILE__) + '/mockdata/base64/*.460') do |data64|
      @data64[File.basename(data64)] = File.open(data64, "r").read
    end

    Dir.glob(File.expand_path("..", __FILE__) + '/mockdata/malformed/*.malf') do |malformed|
      @data_wrong[File.basename(malformed)] = File.open(malformed, "r").read
    end

    Dir.glob(File.expand_path("..", __FILE__) + '/mockdata/xml/*.460') do |xml|
      @data[File.basename(xml)] = File.open(xml, "r").read
    end

    # Notifier instance
    @notifier = Notifier.new(:syslog, @logger)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown
    # Do nothing
  end

  def test_decode_base64

    @data64.each do |name, encoded|
      assert_equal(@data[name], @notifier.decode_base64(encoded), "Encoded and decoded data should match!")
    end

    @data64.each do |name, encoded|
      @data.each do |named, xml|
        assert_not_equal(xml, @notifier.decode_base64(encoded), "Random and decoded data should not match!") unless name.eql? named
      end
    end

    assert_empty(@notifier.decode_base64(""))

  end

  def test_read_template

    @data.each do |name, xml|
      assert_instance_of(VMTemplate, read_template = @notifier.read_template(xml))
      assert_equal(460, read_template.ID)
    end    

    @data_wrong.each do |name, malformed|
      assert_raise Nokogiri::XML::SyntaxError do
        @notifier.read_template(malformed)
      end
    end

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
