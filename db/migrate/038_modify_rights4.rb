# -*- encoding : utf-8 -*-
class ModifyRights4 < ActiveRecord::Migration
  def self.up
  
    writer = Role.find(:first, :conditions => [ "name = ?", "Writer"])
    local_admin = Role.find(:first, :conditions => [ "name = ?", "Local Admin"])
    admin = Role.find(:first, :conditions => [ "name = ?", "Admin"])
    member = Role.find(:first, :conditions => [ "name = ?", "Member"])
  
    new_tagging = Right.create(:name => "New Tagging", :controller => "taggings", :action => "new")
    new_tagging.roles << writer
    new_tagging.roles << local_admin
    new_tagging.roles << admin
    new_tagging.roles << member
    create_tagging = Right.create(:name => "Create Tagging", :controller => "taggings", :action => "create")
    create_tagging.roles << writer
    create_tagging.roles << local_admin
    create_tagging.roles << admin
    create_tagging.roles << member
    edit_tagging = Right.create(:name => "Edit Tagging", :controller => "taggings", :action => "edit")
    edit_tagging.roles << writer
    edit_tagging.roles << local_admin
    edit_tagging.roles << admin
    edit_tagging.roles << member
    update_tagging = Right.create(:name => "Update Tagging", :controller => "taggings", :action => "update")
    update_tagging.roles << writer
    update_tagging.roles << local_admin
    update_tagging.roles << admin
    update_tagging.roles << member
    destroy_tagging = Right.create(:name => "Destroy Tagging", :controller => "taggings", :action => "destroy")
    destroy_tagging.roles << writer
    destroy_tagging.roles << local_admin
    destroy_tagging.roles << admin
    destroy_tagging.roles << member
    count_taggings = Right.create(:name => "Count Taggings", :controller => "taggings", :action => "count")
    count_taggings.roles << local_admin
    count_taggings.roles << admin
  end

  def self.down
  end
end
