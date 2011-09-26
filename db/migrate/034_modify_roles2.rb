# -*- encoding : utf-8 -*-
class ModifyRoles2 < ActiveRecord::Migration
  def self.up
    
    member = Role.create(:name => "Member")
    member.save!

  end

  def self.down
    #TODO
  end
end
