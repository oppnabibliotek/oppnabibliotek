# -*- encoding : utf-8 -*-
class CreateSignums < ActiveRecord::Migration
  def self.up
    create_table :signums do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :signums
  end
end
