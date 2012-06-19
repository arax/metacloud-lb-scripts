require 'ostruct'
require 'optparse'

class OptparseNotifier

  def self.parse(args)

    options = OpenStruct.new 
    options.service = :syslog
    options.debug = false
    options.mapfile = nil

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: metacloud-notify.rb [OPTIONS]"

      opts.separator ""
      opts.separator "Options:"

      opts.on("--vm-state [STATE]", [:create, :CREATE, :prolog, :PROLOG, :running, :RUNNING, :shutdown, :SHUTDOWN, :stop, :STOP, :done, :DONE, :failed, :FAILED], "Name of the ON hook that has been triggered, mandatory") do |vm_state|
        options.vm_state = vm_state.downcase
      end

      opts.on("--vm-template [TEMPLATE]", String, "Base64 encoded XML of the VM template, mandatory") do |vm_template|
        options.vm_template = vm_template
      end

      opts.on("--service-to-notify [SERVICE]", [:syslog, :metalb], "Service you wish to notify [syslog|metalb], defaults to syslog") do |service|
        options.service = service
      end

      opts.on("--mapfile [PATH_TO_FILE]", String, "Path to a mapfile in YAML format") do |mapfile|
        raise ArgumentError, "The chosen mapfile does not exist or it is not readable" unless File.exists? mapfile or File.readable? mapfile
        options.mapfile = mapfile
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

        exit!
      end

    end

    begin
      opts.parse!(args)
    rescue Exception => ex
      puts ex.message.capitalize
      puts opts
      exit!
    end

    mandatory = [:service, :vm_template, :vm_state]
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
