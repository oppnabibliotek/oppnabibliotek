# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
# == Schema Information
# Schema version: 55
#
# Table name: images
#
#  id           :integer(4)      not null, primary key
#  edition_id   :integer(4)
#  size         :integer(4)
#  width        :integer(4)
#  height       :integer(4)
#  content_type :string(255)
#  filename     :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  temp_imageid :integer(4)
#

class Image < ActiveRecord::Base
  belongs_to :edition
  has_attached_file :content, :styles => { :medium => "300x300>", :thumb => "100x100>" }
#  has_attachment :content_type => :image,
#                 :storage => :file_system,
#                 :size => 0.megabyte..1.megabyte
#
#  validates_as_attachment
  
end
