# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
# == Schema Information
# Schema version: 55
#
# Table name: taggings
#
#  id         :integer(4)      not null, primary key
#  tag_id     :integer(4)      not null
#  user_id    :integer(4)      not null
#  book_id    :integer(4)      not null
#  edition_id :integer(4)
#  published  :boolean(1)
#  created_at :datetime
#  updated_at :datetime
#

class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :book
  belongs_to :edition
  belongs_to :user
  validates_uniqueness_of :edition_id, :scope => [:user_id, :book_id, :tag_id] , :message => "has already been tagged with this tag by this user."
end
