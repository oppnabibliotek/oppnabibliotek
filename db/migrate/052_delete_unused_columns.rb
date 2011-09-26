# -*- encoding : utf-8 -*-
class DeleteUnusedColumns < ActiveRecord::Migration
  def self.up
    #remove_column :books, :temp_bookid
    #remove_column :books, :temp_signumtext
    #remove_column :counties, :temp_countyid
    #remove_column :editions, :temp_bookid
    #remove_column(:images, :temp_imageid)
    #remove_column(:libraries, :temp_libaryid)
    #remove_column(:users, :temp_userid)
  end

  def self.down
  end
  
end
