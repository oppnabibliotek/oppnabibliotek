# -*- encoding : utf-8 -*-
class ModifyRights2 < ActiveRecord::Migration
  def self.up
  
    writer = Role.find(:first, :conditions => [ "name = ?", "Writer"])
    local_admin = Role.find(:first, :conditions => [ "name = ?", "Local Admin"])
    admin = Role.find(:first, :conditions => [ "name = ?", "Admin"])
    member = Role.find(:first, :conditions => [ "name = ?", "Member"])
  
    new_assessment = Right.create(:name => "New Assessment", :controller => "assessments", :action => "new")
    new_assessment.roles << writer
    new_assessment.roles << local_admin
    new_assessment.roles << admin
    new_assessment.roles << member
    create_assessment = Right.create(:name => "Create Assessment", :controller => "assessments", :action => "create")
    create_assessment.roles << writer
    create_assessment.roles << local_admin
    create_assessment.roles << admin
    create_assessment.roles << member
    edit_assessment = Right.create(:name => "Edit Assessment", :controller => "assessments", :action => "edit")
    edit_assessment.roles << writer
    edit_assessment.roles << local_admin
    edit_assessment.roles << admin
    edit_assessment.roles << member
    update_assessment = Right.create(:name => "Update Assessment", :controller => "assessments", :action => "update")
    update_assessment.roles << writer
    update_assessment.roles << local_admin
    update_assessment.roles << admin
    update_assessment.roles << member
    destroy_assessment = Right.create(:name => "Destroy Assessment", :controller => "assessments", :action => "destroy")
    destroy_assessment.roles << writer
    destroy_assessment.roles << local_admin
    destroy_assessment.roles << admin
    destroy_assessment.roles << member
    
  end

  def self.down
  end
end
