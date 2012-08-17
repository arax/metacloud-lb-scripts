task :default => [:test_unit, :test_syslog]

task :test_unit do
  ruby "test/notifier_test.rb"
end

task :test_syslog do
  vm_states = [:create, :prolog, :running, :shutdown, :done, :failed, :stop]

  vm_states.each do |vm_state|
    ruby "metacloud-notify.rb --vm-state #{vm_state.to_s.upcase} --vm-template `cat test/mockdata/base64/#{vm_state.to_s.upcase}.460` --service-to-notify syslog --debug --mapfile test/mockdata/mapfile"
  end
end
