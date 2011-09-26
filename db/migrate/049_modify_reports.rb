# -*- encoding : utf-8 -*-
class ModifyReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :description_id, :integer
  end

  def self.down
    remove_column :reports, :description_id, :integer
  end
  
end
