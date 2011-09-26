# -*- encoding : utf-8 -*-
class ModifyLibraries3 < ActiveRecord::Migration
  def self.up
    add_column :libraries, :abuse_email, :string
  end

  def self.down
    remove_column :libraries, :abuse_email, :string
  end
  
end
