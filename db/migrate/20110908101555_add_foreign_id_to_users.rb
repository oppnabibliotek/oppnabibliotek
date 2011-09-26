# -*- encoding : utf-8 -*-
class AddForeignIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :foreign_id, :string
  end

  def self.down
    remove_column :users, :foreign_id
  end
end
