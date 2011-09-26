# -*- encoding : utf-8 -*-
class CreateLibraries < ActiveRecord::Migration
  def self.up
    create_table :libraries do |t|
      t.string :name
      t.integer :county_id
      t.timestamps
    end
  end

  def self.down
    drop_table :libraries
  end
end
