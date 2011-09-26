# -*- encoding : utf-8 -*-
class ModifyRights5 < ActiveRecord::Migration
  def self.up
    
    writer = Role.find(:first, :conditions => [ "name = ?", "Writer"])
    local_admin = Role.find(:first, :conditions => [ "name = ?", "Local Admin"])
    admin = Role.find(:first, :conditions => [ "name = ?", "Admin"])
    member = Role.find(:first, :conditions => [ "name = ?", "Member"])
    
    new_tag = Right.create(:name => "New Tag", :controller => "tags", :action => "new")
    new_tag.roles << writer
    new_tag.roles << local_admin
    new_tag.roles << admin
    new_tag.roles << member
    create_tag = Right.create(:name => "Create Tag", :controller => "tags", :action => "create")
    create_tag.roles << writer
    create_tag.roles << local_admin
    create_tag.roles << admin
    create_tag.roles << member
    edit_tag = Right.create(:name => "Edit Tag", :controller => "tags", :action => "edit")
    edit_tag.roles << writer
    edit_tag.roles << local_admin
    edit_tag.roles << admin
    edit_tag.roles << member
    update_tag = Right.create(:name => "Update Tag", :controller => "tags", :action => "update")
    update_tag.roles << writer
    update_tag.roles << local_admin
    update_tag.roles << admin
    update_tag.roles << member
    destroy_tag = Right.create(:name => "Destroy Tag", :controller => "tags", :action => "destroy")
    destroy_tag.roles << writer
    destroy_tag.roles << local_admin
    destroy_tag.roles << admin
    destroy_tag.roles << member
    
  end
  
  def self.down
  end
end
