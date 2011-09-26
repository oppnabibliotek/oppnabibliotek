# -*- encoding : utf-8 -*-
class CreateDescriptions < ActiveRecord::Migration
  def self.up
    create_table :descriptions do |t|
      t.text :text
      t.integer :edition_id
      t.timestamps
    end
  end

  def self.down
    drop_table :descriptions
  end
end
