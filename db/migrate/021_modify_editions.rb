# -*- encoding : utf-8 -*-
class ModifyEditions < ActiveRecord::Migration
  def self.up
    add_column :editions, :recordnr, :integer
    add_column :editions, :recordcompany, :string
    add_column :editions, :auxcreator, :string
    add_column :editions, :mediatype, :string
    add_column :editions, :mediatypecode, :string
    add_column :editions, :ssb_key, :string
  end
  
  def self.down
    remove_column :editions, :recordnr
    remove_column :editions, :recordcompany
    remove_column :editions, :auxcreator
    remove_column :editions, :mediatype
    remove_column :editions, :mediatypecode
    remove_column :editions, :ssb_key
  end
end
