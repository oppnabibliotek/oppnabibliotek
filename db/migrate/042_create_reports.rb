# -*- encoding : utf-8 -*-
class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :reports do |t|
      t.integer :user_id
      t.string  :subject
      t.string  :message
      t.integer :tag_id
      t.integer :assessment_id
      t.timestamps
    end
  end

  def self.down
    drop_table :reports
  end
end
