# -*- encoding : utf-8 -*-
class AddEditions < ActiveRecord::Migration
  def self.up
    add_column :editions, :translator , :string
  end

  def self.down
    remove_column :editions, :translator
  end
end
