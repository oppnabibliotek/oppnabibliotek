# -*- encoding : utf-8 -*-
class ModifyRoles < ActiveRecord::Migration
  def self.up
    writer = Role.find(:first, :conditions => [ "name = ?", "Writer"])
    
    show_user = Right.find(:first, :conditions => [ "name = ?", "Show user"])
    show_user.roles << writer
    update_user = Right.find(:first, :conditions => [ "name = ?", "Update User"])
    update_user.roles << writer

  end

  def self.down
    #TODO
  end
end
