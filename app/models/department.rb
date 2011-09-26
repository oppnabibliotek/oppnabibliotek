# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
# == Schema Information
# Schema version: 55
#
# Table name: departments
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  ssbid      :string(255)
#  library_id :integer(4)
#

class Department < ActiveRecord::Base
  belongs_to :library
  has_and_belongs_to_many :users
  
   validates_presence_of :name,:library_id,
                        :message => "can't be empty"
end
