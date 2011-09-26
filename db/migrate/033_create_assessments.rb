# -*- encoding : utf-8 -*-
class CreateAssessments < ActiveRecord::Migration
  def self.up
    create_table :assessments do |t|
      t.integer :grade
      t.boolean :published
      t.integer :user_id
      t.integer :book_id
      t.integer :edition_id
      t.text :comment_header
      t.text :comment_text

      t.timestamps
    end
  end

  def self.down
    drop_table :assessments
  end
end
