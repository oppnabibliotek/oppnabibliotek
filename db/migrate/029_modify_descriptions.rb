# -*- encoding : utf-8 -*-
class ModifyDescriptions < ActiveRecord::Migration
  def self.up
    add_column :descriptions, :source_id, :string
  end

  def self.down
    remove_column :descriptions, :source_id
  end
end
