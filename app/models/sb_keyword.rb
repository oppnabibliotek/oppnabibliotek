# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
# == Schema Information
# Schema version: 55
#
# Table name: sb_keywords
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  namecode   :string(255)
#

class SbKeyword < ActiveRecord::Base
   has_and_belongs_to_many :books
   validates_presence_of  :name, 
                          :message => "can't be empty"
end
