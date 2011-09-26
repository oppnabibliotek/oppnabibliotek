# -*- encoding : utf-8 -*-
class ModifyEditions2 < ActiveRecord::Migration
  def self.up
    add_column :editions, :imageurl, :string
    add_column :editions, :published, :boolean
    add_column :editions, :manual, :boolean
  end
  
  def self.down
    remove_column :editions, :imageurl
    remove_column :editions, :published
    remove_column :editions, :manual
  end
end
