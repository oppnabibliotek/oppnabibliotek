# -*- encoding : utf-8 -*-
class ModifyBooks2 < ActiveRecord::Migration
  def self.up
    add_column :books, :targetgroup_id, :integer
    add_column :books, :agegroup_id, :integer
  end

  def self.down
    remove_column :books, :agegroup_id
    remove_column :books, :targetgroup_id
   end
end
