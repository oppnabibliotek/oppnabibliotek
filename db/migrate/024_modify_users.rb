# -*- encoding : utf-8 -*-
class ModifyUsers < ActiveRecord::Migration
  def self.up
    
    create_table :departments_users, :id => false do |t|
      t.column "department_id", :integer
      t.column "user_id", :integer
    end
   
    create_table :departments do |t|
      t.column "name", :string
      t.column "ssbid", :string
      t.column "library_id", :integer
    end

  end
  
  def self.down
    drop_table :departments_users
    drop_table :departments
  end
end
