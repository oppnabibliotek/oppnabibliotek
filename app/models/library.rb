# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
# == Schema Information
# Schema version: 55
#
# Table name: libraries
#
#  id                    :integer(4)      not null, primary key
#  name                  :string(255)
#  county_id             :integer(4)
#  created_at            :datetime
#  updated_at            :datetime
#  userinfolink          :text
#  infolink              :text
#  bookinfolink          :text
#  temp_libaryid         :integer(4)
#  searchstring_encoding :text
#  stylesheet            :text
#  keep_isbn_dashes      :boolean(1)
#  abuse_email           :string(255)
#  dev_key               :string(255)
#

class Library < ActiveRecord::Base
  has_many :users
  has_many :descriptions
  belongs_to :county
  has_many :departments
  
  validates_presence_of  :name, :county_id, :message => "can't be empty"
end
