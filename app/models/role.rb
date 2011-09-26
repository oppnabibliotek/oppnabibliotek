# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
# == Schema Information
# Schema version: 55
#
# Table name: roles
#
#  id   :integer(4)      not null, primary key
#  name :string(255)
#

class Role < ActiveRecord::Base
  include Comparable
  
  has_and_belongs_to_many :users
  has_and_belongs_to_many :rights


  scope :admin, where(:name => "Admin")
  scope :local_admin, where(:name => "Local Admin")
  scope :writer, where(:name => "Writer")
  scope :member, where(:name => "Member")
  scope :moreThanMember, where(:name => ["Admin", "Local Admin", "Writer"])

  # This depends on the roles being created in the right order, so that e.g. the id for "Writer"
  # is less than that for "Local Admin".
  def <=>(other)
    id <=> other.id
  end
  
end
