# -*- encoding : utf-8 -*-
class ModifyLibraries2 < ActiveRecord::Migration
  def self.up
    add_column :libraries, :searchstring_encoding, :text
    add_column :libraries, :stylesheet, :text
    add_column :libraries, :keep_isbn_dashes, :boolean
  end

  def self.down
    remove_column :libraries, :searchstring_encoding
    remove_column :libraries, :stylesheet
    remove_column :libraries, :keep_isbn_dashes
  end
end
