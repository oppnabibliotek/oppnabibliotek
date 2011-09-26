# -*- encoding : utf-8 -*-
class ModifyRights10 < ActiveRecord::Migration
  def self.up
    
    local_admin = Role.find(:first, :conditions => [ "name = ?", "Local Admin"])
    admin = Role.find(:first, :conditions => [ "name = ?", "Admin"])
    
    index_blacklistings = Right.create(:name => "Index Blacklisting", :controller => "blacklistings", :action => "index")
    index_blacklistings.roles << local_admin
    index_blacklistings.roles << admin
    show_blacklisting = Right.create(:name => "Show Blacklisting", :controller => "blacklistings", :action => "show")
    show_blacklisting.roles << local_admin
    show_blacklisting.roles << admin
    
  end
  
  def self.down
  end
end
