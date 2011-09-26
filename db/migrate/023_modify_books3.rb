# -*- encoding : utf-8 -*-
class ModifyBooks3 < ActiveRecord::Migration
  def self.up
    add_column :books, :booktitle_part1, :string
    add_column :books, :booktitle_part2, :string
    add_column :books, :group_inst, :string
  end
  
  def self.down
    remove_column :books, :booktitle_part1
    remove_column :books, :booktitle_part2
    remove_column :books, :group_inst
  end
end
