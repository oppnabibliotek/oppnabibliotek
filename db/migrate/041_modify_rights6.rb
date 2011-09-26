# -*- encoding : utf-8 -*-
class ModifyRights6 < ActiveRecord::Migration
  def self.up
    
    local_admin = Role.find(:first, :conditions => [ "name = ?", "Local Admin"])
    admin = Role.find(:first, :conditions => [ "name = ?", "Admin"])
    
    new_blacklisting = Right.create(:name => "New Blacklisting", :controller => "blacklistings", :action => "new")
    new_blacklisting.roles << local_admin
    new_blacklisting.roles << admin
    create_blacklisting = Right.create(:name => "Create Blacklisting", :controller => "blacklistings", :action => "create")
    create_blacklisting.roles << local_admin
    create_blacklisting.roles << admin
    edit_blacklisting = Right.create(:name => "Edit Blacklisting", :controller => "blacklistings", :action => "edit")
    edit_blacklisting.roles << local_admin
    edit_blacklisting.roles << admin
    update_blacklisting = Right.create(:name => "Update Blacklisting", :controller => "blacklistings", :action => "update")
    update_blacklisting.roles << local_admin
    update_blacklisting.roles << admin
    destroy_blacklisting = Right.create(:name => "Destroy Blacklisting", :controller => "blacklistings", :action => "destroy")
    destroy_blacklisting.roles << local_admin
    destroy_blacklisting.roles << admin
    
  end
  
  def self.down
  end
end
