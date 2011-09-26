# -*- encoding : utf-8 -*-
class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :name

      t.timestamps
    end

    create_table :taggings do |t|
      t.integer :tag_id, :null => false
      t.integer :user_id, :null => false
      t.integer :book_id, :null => false
      t.integer :edition_id
      t.boolean :published
      t.timestamps
    end

  end

  def self.down
    drop_table :tags
    drop_table :taggings
  end
end
