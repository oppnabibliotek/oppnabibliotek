# -*- encoding : utf-8 -*-
class ModifyRights12 < ActiveRecord::Migration
  def self.up
    
    writer = Role.find(:first, :conditions => [ "name = ?", "Writer"])
    member = Role.find(:first, :conditions => [ "name = ?", "Member"])
    
    edit_tag = Right.find(:first, :conditions => [ "name = ?", "Edit Tag"])
    edit_tag.roles.delete(member)
    edit_tag.roles.delete(writer)
    
    update_tag = Right.find(:first, :conditions => [ "name = ?", "Update Tag"])
    update_tag.roles.delete(member)
    update_tag.roles.delete(writer)
    
    destroy_tag = Right.find(:first, :conditions => [ "name = ?", "Destroy Tag"])
    destroy_tag.roles.delete(member)
    destroy_tag.roles.delete(writer)
    
  end
  
  def self.down
  end
end
