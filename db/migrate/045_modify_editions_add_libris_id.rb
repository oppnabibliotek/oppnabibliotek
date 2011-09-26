# -*- encoding : utf-8 -*-
class ModifyEditionsAddLibrisId < ActiveRecord::Migration
  def self.up
    add_column :editions, :libris_id, :integer
  end

  def self.down
    remove_column :editions, :libris_id, :integer
  end
  
end
