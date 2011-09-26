# -*- encoding : utf-8 -*-
class CreateTargetgroups < ActiveRecord::Migration
  def self.up
    create_table :targetgroups do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :targetgroups
  end
end
