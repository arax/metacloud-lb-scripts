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

require 'erb'
require 'open3'
require 'sequel'

class MetalbService

  def initialize(notifier_name = "OpenNebulaMetaLBNotifier")
    # we need a DB for VMID <-> JOBID mappings
    @db = Sequel.sqlite 'metacloud-notify.sqlite'
    
    # create lb_jobs table if there isn't one already available
    unless @db.tables.include? :lb_jobs
     @db.create_table :lb_jobs do
        primary_key :vmid
        String :lbjobid, :unique => true, :null => false
        DateTime :created_at
      end
    end
  end

  def write(message)
    stdin, stdout, stderr, wait_thr = Open3.popen3(message)

    cmd_out = stdout.read
    putMapping(@current_vmid, cmd_out) if @current_state == :create and cmd_out.start_with? "https://" 

    stdin.close
    stdout.close
    stderr.close

    delMapping(@current_vmid) if @current_state == :done

    exit_status = wait_thr.value
  end

  def prepare_message(vm_state, user_identity, vm_template)

    @current_vmid = vm_template.ID
    @current_state = vm_state

    edg_jobid = getMapping(@current_vmid)
    edg_jobid = "" if edg_jobid.nil?    

    edg_wl_sequence="UI=000000:NS=0000000000:WM=000000:BH=0000000000:JSS=000000:LM=000000:LRMS=000000:APP=000004:LBS=000000"

    msg_template = ERB.new File.new(File.expand_path("..", __FILE__) + "/templates/metalb.erb").read
    msg_template.result(binding)

  end

  def putMapping(vmid, jobid)
    @db[:lb_jobs].insert(:vmid => vmid, :lbjobid => jobid)
  end

  def getMapping(vmid)
    ds = @db[:lb_jobs].where(:vmid => vmid)

    if ds.count == 1
      ds.first[:lbjobid]
    else
      nil
    end
  end

  def delMapping(vmid)
    @db[:lb_jobs].filter(:vmid => vmid).delete
  end

end
