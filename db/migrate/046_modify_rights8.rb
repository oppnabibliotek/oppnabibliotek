# -*- encoding : utf-8 -*-
class ModifyRights8 < ActiveRecord::Migration
  def self.up
    writer = Role.find(:first, :conditions => [ "name = ?", "Writer"])
    member = Role.find(:first, :conditions => [ "name = ?", "Member"])
    local_admin = Role.find(:first, :conditions => [ "name = ?", "Local Admin"])
    admin = Role.find(:first, :conditions => [ "name = ?", "Admin"])
    
    usersearch = Right.create(:name => "User search", :controller => "users", :action => "usersearch")
    usersearch.roles << local_admin
    usersearch.roles << admin

    librarysearch = Right.create(:name => "Library search", :controller => "libraries", :action => "librarysearch")
    librarysearch.roles << local_admin
    librarysearch.roles << admin

    show = Right.find(:first, :conditions => [ "name = ?", "Show user"])
    show.roles << member
    update = Right.find(:first, :conditions => [ "name = ?", "Update User"])
    update.roles << member
    byusername = Right.find(:first, :conditions => [ "name = ?", "By username"])
    byusername.roles << member

  end

  def self.down
  end
end
