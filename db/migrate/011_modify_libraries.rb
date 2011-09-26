# -*- encoding : utf-8 -*-
class ModifyLibraries < ActiveRecord::Migration
  def self.up
    add_column :libraries, :userinfolink, :text
    add_column :libraries, :infolink, :text
    add_column :libraries, :bookinfolink, :text
  end

  def self.down
    remove_column :libraries, :userinfolink
    remove_column :libraries, :infolink
    remove_column :libraries, :bookinfolink
  end
  
end
