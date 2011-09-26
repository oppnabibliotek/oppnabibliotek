# -*- encoding : utf-8 -*-
class ModifyBlacklistings < ActiveRecord::Migration
  def self.up
    add_column :blacklistings, :description_id, :integer
  end

  def self.down
    remove_column :blacklistings, :description_id, :integer
  end
  
end
