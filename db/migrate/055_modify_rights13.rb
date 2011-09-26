# -*- encoding : utf-8 -*-
class ModifyRights13 < ActiveRecord::Migration
  def self.up
    
    member = Role.find(:first, :conditions => [ "name = ?", "Member"])
    
    show_users = Right.find(:first, :conditions => [ "name = ?", "Show users"])

    show_users.roles << member

  end
  
  def self.down
  end
end
