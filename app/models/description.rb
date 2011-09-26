# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
# == Schema Information
# Schema version: 55
#
# Table name: descriptions
#
#  id         :integer(4)      not null, primary key
#  text       :text
#  edition_id :integer(4)
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer(4)
#  source_id  :string(255)
#

class Description < ActiveRecord::Base

  belongs_to :edition
  belongs_to :user
  belongs_to :library
  
  attr_accessor :show_after_search
  
  #validates_presence_of :text, 
  #                      :message => "can't be empty"


  def save_and_index
    returnvalue = save
    self.edition.book.ferret_update if self.edition && self.edition.book
    return returnvalue
  end
  
  def update_attributes_and_index(params)
    returnvalue = update_attributes(params)
    self.edition.book.ferret_update if self.edition && self.edition.book
    return returnvalue
  end
  
end
