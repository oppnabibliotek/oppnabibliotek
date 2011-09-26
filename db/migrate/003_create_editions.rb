# -*- encoding : utf-8 -*-
class CreateEditions < ActiveRecord::Migration
  def self.up
    create_table :editions do |t|
      t.string :isbn, :illustrator
      t.integer :year
      t.integer :book_id
      t.timestamps
    end
  end

  def self.down
    drop_table :editions
  end
end
