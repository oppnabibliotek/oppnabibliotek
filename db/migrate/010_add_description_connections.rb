# -*- encoding : utf-8 -*-
class AddDescriptionConnections < ActiveRecord::Migration
  def self.up
    add_column :descriptions, :user_id, :integer
  end

  def self.down
    remove_column :descriptions, :user_id
  end
end
