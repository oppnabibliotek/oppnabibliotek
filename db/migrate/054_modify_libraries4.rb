# -*- encoding : utf-8 -*-
class ModifyLibraries4 < ActiveRecord::Migration
  def self.up
    add_column :libraries, :dev_key, :string
  end

  def self.down
    remove_column :libraries, :dev_key, :string
  end
  
end
