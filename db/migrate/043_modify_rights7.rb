# -*- encoding : utf-8 -*-
class ModifyRights7 < ActiveRecord::Migration
  def self.up
    
    writer = Role.find(:first, :conditions => [ "name = ?", "Writer"])
    local_admin = Role.find(:first, :conditions => [ "name = ?", "Local Admin"])
    admin = Role.find(:first, :conditions => [ "name = ?", "Admin"])
    member = Role.find(:first, :conditions => [ "name = ?", "Member"])
    
    new_report = Right.create(:name => "New Report", :controller => "reports", :action => "new")
    new_report.roles << local_admin
    new_report.roles << admin
    new_report.roles << member
    new_report.roles << writer
    create_report = Right.create(:name => "Create Report", :controller => "reports", :action => "create")
    create_report.roles << local_admin
    create_report.roles << admin
    create_report.roles << member
    create_report.roles << writer
    edit_report = Right.create(:name => "Edit Report", :controller => "reports", :action => "edit")
    edit_report.roles << local_admin
    edit_report.roles << admin
    update_report = Right.create(:name => "Update Report", :controller => "reports", :action => "update")
    update_report.roles << local_admin
    update_report.roles << admin
    destroy_report = Right.create(:name => "Destroy Report", :controller => "reports", :action => "destroy")
    destroy_report.roles << local_admin
    destroy_report.roles << admin
    
    report_abuse = Right.create(:name => "Report Abuse", :controller => "reports", :action => "reportabuse")
    report_abuse.roles << local_admin
    report_abuse.roles << admin
    report_abuse.roles << member
    report_abuse.roles << writer
    
    notify_abuser = Right.create(:name => "Notify Abuser", :controller => "reports", :action => "notifyabuser")
    notify_abuser.roles << local_admin
    notify_abuser.roles << admin
    
  end
  
  def self.down
  end
end
