# -*- encoding : utf-8 -*-
class CreateAgegroups < ActiveRecord::Migration
  def self.up
    create_table :agegroups do |t|
      t.string :name
      t.integer :targetgroup_id
      t.integer :from
      t.integer :to

      t.timestamps
    end
  end

  def self.down
    drop_table :agegroups
  end
end
