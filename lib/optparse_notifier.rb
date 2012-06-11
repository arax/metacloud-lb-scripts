require 'ostruct'
require 'optparse'

class OptparseNotifier

  def self.parse(args)

    options = OpenStruct.new 
    options.service = :syslog

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: metacloud-notify.rb [OPTIONS]"

      opts.separator ""
      opts.separator "Options:"

      opts.on("--vm-template [TEMPLATE]", String, "Base64 encoded XML of the VM template, mandatory") do |vm_template|
        options.vm_template = vm_template
      end

      opts.on("--service-to-notify [SERVICE]", [:syslog, :metalb], "Service you wish to notify [syslog|metalb], defaults to syslog") do |service|
        options.service = service
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

    mandatory = [:service, :vm_template]
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
