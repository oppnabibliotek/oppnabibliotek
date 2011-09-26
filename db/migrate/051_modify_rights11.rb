# -*- encoding : utf-8 -*-
class ModifyRights11 < ActiveRecord::Migration
  def self.up
    
    local_admin = Role.find(:first, :conditions => [ "name = ?", "Local Admin"])
    admin = Role.find(:first, :conditions => [ "name = ?", "Admin"])
    
    count_tags = Right.create(:name => "Count Tags", :controller => "tags", :action => "count")
    count_tags.roles << local_admin
    count_tags.roles << admin
    
  end
  
  def self.down
  end
end
