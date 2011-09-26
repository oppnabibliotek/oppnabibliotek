# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
# == Schema Information
# Schema version: 55
#
# Table name: assessments
#
#  id             :integer(4)      not null, primary key
#  grade          :integer(4)
#  published      :boolean(1)
#  user_id        :integer(4)
#  book_id        :integer(4)
#  edition_id     :integer(4)
#  comment_header :text
#  comment_text   :text
#  created_at     :datetime
#  updated_at     :datetime
#

class Assessment < ActiveRecord::Base

  belongs_to :book
  belongs_to :edition
  belongs_to :user
  has_many :blacklistings
  validates_uniqueness_of :edition_id, :scope => [:user_id, :book_id] , :message => "has already been assessed by this user."

end
