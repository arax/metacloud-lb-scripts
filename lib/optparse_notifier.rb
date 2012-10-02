require 'ostruct'
require 'optparse'

class OptparseNotifier

  def self.parse(args)

    options = OpenStruct.new 
    options.service = :syslog
    options.debug = false
    options.mapfile = nil
    options.log_to = :stdout
    options.log_to_file = "log/metacloud-notify.log"
    options.krb_realm = "MYREALM"
    options.krb_host_realm = "MYHOSTREALM"

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: metacloud-notify.rb --vm-state STATE --vm-template TEMPLATE [OPTIONS]"

      opts.separator ""
      opts.separator "Options:"

      opts.on("--vm-state STATE", [:create, :CREATE, :prolog, :PROLOG, :running, :RUNNING, :shutdown, :SHUTDOWN, :stop, :STOP, :done, :DONE, :failed, :FAILED], "Name of the ON hook that has been triggered, mandatory") do |vm_state|
        options.vm_state = vm_state.to_s.downcase.to_sym
      end

      opts.on("--vm-template TEMPLATE", String, "Base64 encoded XML of the VM template, mandatory") do |vm_template|
        options.vm_template = vm_template
      end

      opts.on("--service-to-notify SERVICE", [:syslog, :metalb], "Service you wish to notify [syslog|metalb], defaults to syslog") do |service|
        options.service = service
      end

      opts.on("--mapfile PATH_TO_FILE", String, "Path to a mapfile in YAML format") do |mapfile|
        raise ArgumentError, "The chosen mapfile does not exist or it is not readable" unless File.exists? mapfile or File.readable? mapfile
        options.mapfile = mapfile
      end

      opts.on("--log-to OUTPUT", [:stdout, :stderr, :file], "Logger type [stdout|stderr|file], defaults to stdout") do |log_to|
        options.log_to = log_to
      end

      opts.on("--log-to-file FILE", String, "Log file, defaults to 'log/metacloud-notify.log'") do |log_to_file|
        options.log_to_file = log_to_file
      end

      opts.on("--krb-realm MYREALM", String, "Krb5 realm for ON users, defaults to 'MYREALM'") do |krb_realm|
        options.krb_realm = krb_realm
      end

      opts.on("--krb-host-realm MYHOSTREALM", String, "Krb5 realm for virtual machines (host/HOSTNAME@MYHOSTREALM), defaults to 'MYHOSTREALM'") do |krb_host_realm|
        options.krb_host_realm = krb_host_realm
      end

      opts.on_tail("--debug", "Enable debugging messages") do |debug|
        options.debug = debug
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit!
      end

      opts.on_tail("--version", "Show version") do
        begin
	        file = File.new(File.expand_path("..", __FILE__) + '/../VERSION', "r")
	        line = file.gets

          puts line

	        file.close
        rescue
	        puts 'UNKNOWN'
        end

        exit!(true)
      end

    end

    begin
      opts.parse!(args)
    rescue Exception => ex
      puts ex.message.capitalize
      puts opts
      exit!
    end

    mandatory = [:service, :vm_template, :vm_state, :log_to, :log_to_file, :krb_realm, :krb_host_realm]
    options_hash = options.marshal_dump

    missing = mandatory.select{ |param| options_hash[param].nil? }
    if not missing.empty?
      puts "Missing required arguments: #{missing.join(', ')}"
      puts opts
      exit!
    end

    options

  end

end
