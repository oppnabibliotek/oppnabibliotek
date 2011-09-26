# -*- encoding : utf-8 -*-
class CreateKeywords < ActiveRecord::Migration
  def self.up
    create_table :keywords do |t|
      t.string :name
      t.timestamps
    end
    
    create_table :books_keywords, :id => false do |t|
      t.column "book_id", :integer
      t.column "keyword_id", :integer
    end
    
  end
  
  def self.down
    drop_table :keywords
    drop_table :books_keywords
  end
end
