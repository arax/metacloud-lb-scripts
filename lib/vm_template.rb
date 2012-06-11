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

require 'happymapper'

class VMTemplate

  include HappyMapper

  tag 'VM'
  element :ID, Integer
  element :UID, Integer
  element :GID, Integer
  element :UNAME, String
  element :GNAME, String
  element :NAME, String
  element :LCM_STATE, Integer
  element :DEPLOY_ID, String
  element :MEMORY, Integer
  element :CPU, Integer

end
