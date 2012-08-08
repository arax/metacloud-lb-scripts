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
      @data64[File.basename data64] = File.open(data64, "r").read
    end

    Dir.glob(File.expand_path("..", __FILE__) + '/mockdata/malformed/*.malf') do |malformed|
      @data_wrong[File.basename malformed] = File.open(malformed, "r").read
    end

    Dir.glob(File.expand_path("..", __FILE__) + '/mockdata/xml/*.460') do |xml|
      @data[File.basename xml] = File.open(xml, "r").read
    end

    # Notifier instance
    @notifier = Notifier.new :syslog, @logger, File.read(File.expand_path("..", __FILE__) + '/mockdata/mapfile')
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown
    # Do nothing
  end

  def test_decode_base64

    @data64.each do |name, encoded|
      assert_equal @data[name], @notifier.decode_base64(encoded), "Encoded and decoded data should match!"
    end

    @data64.each do |name, encoded|
      @data.each do |named, xml|
        assert_not_equal xml, @notifier.decode_base64(encoded), "Random and decoded data should not match!" unless name.eql? named
      end
    end

    assert_empty @notifier.decode_base64 ""

  end

  def test_read_template

    @data.each do |name, xml|
      read_template = @notifier.read_template xml
      assert_instance_of VMTemplate, read_template
      assert_equal 460, read_template.ID
    end    

    @data_wrong.each do |name, malformed|
      assert_raise Nokogiri::XML::SyntaxError do
        @notifier.read_template malformed
      end
    end

  end

  def test_map_user_identity

    assert_equal "/DC=org/DC=terena/DC=tcs/C=CZ/O=Masaryk University/CN=Real Identity 007", @notifier.map_user_identity("oneadmin")
    assert_equal "non-mapped-user", @notifier.map_user_identity("non-mapped-user")

    assert_raise ArgumentError do
      @notifier.map_user_identity ""
    end

    assert_raise ArgumentError do
      @notifier.map_user_identity nil
    end
  
  end

  def test_prepare_notification
  
    assert_raise ArgumentError do
      @notifier.prepare_notification :create, "oneadmin", nil
    end

    assert_raise ArgumentError do
      @notifier.prepare_notification :create, "oneadmin", "NOTVMTEMPLATE", nil
    end
  
  end

  def test_prepare_usage

    assert_raise ArgumentError do
      @notifier.prepare_usage nil, nil
    end

    assert_raise ArgumentError do
      @notifier.prepare_notification "", ""
    end

  end

  def test_notify

    assert_raise ArgumentError do
      @notifier.notify "", nil
    end

    assert_raise ArgumentError do
      @notifier.notify nil, ""
    end

  end
end
