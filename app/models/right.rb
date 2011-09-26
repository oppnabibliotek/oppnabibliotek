# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
# == Schema Information
# Schema version: 55
#
# Table name: rights
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  controller :string(255)
#  action     :string(255)
#

class Right < ActiveRecord::Base
  has_and_belongs_to_many :roles
  
end
