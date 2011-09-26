# -*- encoding : utf-8 -*-
class CreateBlacklistings < ActiveRecord::Migration
  def self.up
    create_table :blacklistings do |t|
      t.integer :tag_id
      t.integer :assessment_id
      t.integer :library_id
      t.boolean :global

      t.timestamps
    end
  end

  def self.down
    drop_table :blacklistings
  end
end
