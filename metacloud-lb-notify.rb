#!/usr/bin/env ruby

require 'syslog'

class MetaLbNotify

  def initialize(notifier_name = "MetaLBNotifier")
    @notifier_name = notifier_name
  end

  def log(message)
    # $0 is the current script name
    Syslog.open(@notifier_name, Syslog::LOG_PID | Syslog::LOG_CONS) { |s| s.warning message }
  end

end

notifier = MetaLbNotify.new
notifier.log "Hello, I'm an LB Notifier for OpenNebula."