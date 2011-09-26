# -*- encoding : utf-8 -*-
class ModifyBooks4 < ActiveRecord::Migration
  def self.up
    add_column :books, :reserved, :boolean
  end
  
  def self.down
    remove_column :books, :reserved
  end
end
