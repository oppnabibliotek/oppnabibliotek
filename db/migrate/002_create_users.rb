# -*- encoding : utf-8 -*-
class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username, :password_hash, :firstname, :lastname, :email
      t.integer :library_id
    end
  end

  def self.down
    drop_table :users
  end
end
