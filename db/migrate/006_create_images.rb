# -*- encoding : utf-8 -*-
class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.integer :edition_id, :size, :width, :height
      t.string :content_type, :filename
      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
