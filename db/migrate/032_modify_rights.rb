# -*- encoding : utf-8 -*-
class ModifyRights < ActiveRecord::Migration
  def self.up
    writer = Role.find(:first, :conditions => [ "name = ?", "Writer"])
    local_admin = Role.find(:first, :conditions => [ "name = ?", "Local Admin"])
    admin = Role.find(:first, :conditions => [ "name = ?", "Admin"])
    
    by_user = Right.create(:name => "By username", :controller => "users", :action => "byusername")
    by_user.roles << writer
    by_user.roles << local_admin
    by_user.roles << admin
  end

  def self.down
  end
end
