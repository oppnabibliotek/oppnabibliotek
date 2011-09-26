# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
# == Schema Information
# Schema version: 55
#
# Table name: tags
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Tag < ActiveRecord::Base

  has_many :taggings, :dependent => :delete_all
  has_many :users, :through => :taggings
  has_many :books, :through => :taggings
  has_many :editions, :through => :taggings
  has_many :blacklistings

end
