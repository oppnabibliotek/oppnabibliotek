# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
# == Schema Information
# Schema version: 55
#
# Table name: blacklistings
#
#  id             :integer(4)      not null, primary key
#  tag_id         :integer(4)
#  assessment_id  :integer(4)
#  library_id     :integer(4)
#  global         :boolean(1)
#  created_at     :datetime
#  updated_at     :datetime
#  description_id :integer(4)
#

class Blacklisting < ActiveRecord::Base
  belongs_to :assessment
  belongs_to :tag
  #validates_uniqueness_of :tag_id, :scope => :library_id, :message => " has already been blacklisted for this library."
  #validates_uniqueness_of :assessment_id, :scope => :library_id, :message => " has already been blacklisted for this library."
  #validates_uniqueness_of :tag_id, :scope => :library_id, :message => " has already been blacklisted for this library."
  #validates_uniqueness_of :tag_id, :scope => [:library_id, :global], :allow => nil, :message => " has already been blacklisted for this library."
  #validates_uniqueness_of :assessment_id, :scope => [:library_id, :global], :allow => nil ,:message => " has already been blacklisted globally or for this library."
end
