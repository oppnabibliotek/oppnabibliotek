# -*- encoding : utf-8 -*-
class CreateSbKeywords < ActiveRecord::Migration
  def self.up
    create_table :sb_keywords do |t|
      t.string :name
      t.timestamps
    end
    
    create_table :books_sb_keywords, :id => false do |t|
      t.column "book_id", :integer
      t.column "sb_keyword_id", :integer
    end
  end
  
  def self.down
    drop_table :sb_keywords
    drop_table :books_sb_keywords
  end
end
