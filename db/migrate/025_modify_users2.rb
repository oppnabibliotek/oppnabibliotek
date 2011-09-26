# -*- encoding : utf-8 -*-
class ModifyUsers2 < ActiveRecord::Migration
  def self.up
    add_column :users, :dynamicinfolink, :string
  end
  
  def self.down
    remove_column :users, :dynamicinfolink
  end
end
