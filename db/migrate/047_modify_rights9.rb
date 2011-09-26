# -*- encoding : utf-8 -*-
class ModifyRights9 < ActiveRecord::Migration
  def self.up
    local_admin = Role.find(:first, :conditions => [ "name = ?", "Local Admin"])
    admin = Role.find(:first, :conditions => [ "name = ?", "Admin"])
    
    dbdump = Right.create(:name => "Get DB dumb", :controller => "users", :action => "dbdump")
    dbdump.roles << local_admin
    dbdump.roles << admin

  end

  def self.down
  end
end
