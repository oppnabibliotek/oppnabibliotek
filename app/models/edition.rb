# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
# == Schema Information
# Schema version: 55
#
# Table name: editions
#
#  id            :integer(4)      not null, primary key
#  isbn          :string(255)
#  illustrator   :string(255)
#  year          :integer(4)
#  book_id       :integer(4)
#  temp_bookid   :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#  translator    :string(255)
#  recordnr      :integer(4)
#  recordcompany :string(255)
#  auxcreator    :string(255)
#  mediatype     :string(255)
#  mediatypecode :string(255)
#  ssb_key       :string(255)
#  imageurl      :string(255)
#  published     :boolean(1)
#  manual        :boolean(1)
#  libris_id     :integer(4)
#

class Edition < ActiveRecord::Base
  belongs_to :book
  has_many :descriptions, :dependent => :delete_all
  has_many :assessments, :dependent => :delete_all
  has_one :image
  has_many :taggings, :dependent => :delete_all
  has_many :tags, :through => :taggings
  
  attr_accessor :uploaded_image_data, :show_after_search
  
  #TODO Vilka fält ska vara tvingande här? 
  # validates_presence_of  :isbn, 
  #                        :message => "can't be empty"
  
  validates_numericality_of :year,
                            :only_integer => true,
                            :allow_nil => true,
                            :message => "must be numerical"
  
  
 # validates_uniqueness_of :isbn,
 #                        :message => "edition already exists"
                           
                           
  
  def save_with_image_and_index
    returnvalue = nil
    image = Image.new
    begin
      self.transaction do
        if uploaded_image_data && uploaded_image_data.size > 0
          image.uploaded_data = uploaded_image_data
          image.save!
          self.image = image
        end
        returnvalue = save
      end
    rescue Exception => details
      logger.error(details)
      if image.errors.on(:size)
        errors.add_to_base("Uploaded image is too big (1 MB max).")
      elsif image.errors.on(:content_type)
        errors.add_to_base("Uploaded image content-type is not valid.")
      else
        errors.add_to_base("Error saving image.")
      end
      return false
    end
    self.book.ferret_update if self.book
    return returnvalue
  end
  
  def update_attributes_and_index(params)
    returnvalue = nil
    image = Image.new
    begin
      self.transaction do
        if params[:uploaded_image_data] && params[:uploaded_image_data].size > 0
          image.uploaded_data = params[:uploaded_image_data]
          image.save!
          self.image = image
        end
        returnvalue = update_attributes(params)
      end
    rescue Exception => details
      logger.error(details)
      if image.errors.on(:size)
        errors.add_to_base("Uploaded image is too big (1 MB max).")
      elsif image.errors.on(:content_type)
        errors.add_to_base("Uploaded image content-type is not valid.")
      else
        errors.add_to_base("Error saving image.")
      end
      return false
    end
    self.book.ferret_update if self.book
    return returnvalue
  end
  
end
