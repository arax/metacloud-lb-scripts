task :default => [:build, :install]

task :install do
  puts "Checking prerequisites..."
  Rake::Task['test:env'].invoke
end

task :build do
  puts "Running tests..."
  Rake::Task['test:unit'].invoke
end

namespace :test do
  task :unit do
    puts "\nRunning unit tests..."
    ruby "test/notifier_test.rb"
  end

  task :env do
    puts "\nChecking ENV variables..."
    puts "ONE_LOCATION              = #{ENV['ONE_LOCATION']}"
    puts "GLITE_LB_DESTINATION      = #{ENV['GLITE_LB_DESTINATION']}"
    puts "GLITE_WMS_LOG_DESTINATION = #{ENV['GLITE_WMS_LOG_DESTINATION']}"

    puts "\nLooking for glite-lb binaries..."

    logev = `which glite-lb-logevent`
    jobreg = `which glite-lb-job_reg`

    puts logev.empty?  ? "glite-lb-logevent not found!" : logev
    puts jobreg.empty? ? "glite-lb-job_reg not found!" : jobreg
  end

  task :exec => :env do
    puts "\nExecuting metacloud-notify.rb..."
    services = [:syslog, :metalb]
    vm_states = [:create, :prolog, :running, :shutdown, :failed, :stop, :done]

    ENV['ONE_LOCATION'] = ""
    ENV['GLITE_LB_DESTINATION'] = "localhost:9000" if ENV['GLITE_LB_DESTINATION'].empty?
    ENV['GLITE_WMS_LOG_DESTINATION'] = "localhost:9002" if ENV['GLITE_WMS_LOG_DESTINATION'].empty?

    services.each do |service|
      vm_states.each do |vm_state|
        ruby "metacloud-notify.rb --vm-state #{vm_state.to_s.upcase} --vm-template `cat test/mockdata/base64/#{vm_state.to_s.upcase}.460` --service-to-notify #{service.to_s} --debug --mapfile test/mockdata/mapfile --krb-realm USERS.EXAMPLE.COM --krb-host-realm VMS.EXAMPLE.COM"
      end
    end
  end
end
