# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
# == Schema Information
# Schema version: 55
#
# Table name: counties
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  temp_countyid :integer(4)
#

class County < ActiveRecord::Base
   has_many :libraries
   
    validates_presence_of  :name, 
                           :message => "can't be empty"
    
end
