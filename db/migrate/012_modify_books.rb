# -*- encoding : utf-8 -*-
class ModifyBooks < ActiveRecord::Migration
  def self.up
    add_column :books, :signum_id, :integer
  end

  def self.down
    remove_column :books, :signum_id
   end
end
