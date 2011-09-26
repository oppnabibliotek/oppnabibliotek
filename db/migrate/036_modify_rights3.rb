# -*- encoding : utf-8 -*-
class ModifyRights3 < ActiveRecord::Migration
  def self.up
    
    local_admin = Role.find(:first, :conditions => [ "name = ?", "Local Admin"])
    admin = Role.find(:first, :conditions => [ "name = ?", "Admin"])

    count_assessment = Right.create(:name => "Count Assessments", :controller => "assessments", :action => "count")
    count_assessment.roles << local_admin
    count_assessment.roles << admin
    
  end

  def self.down
  end
end
