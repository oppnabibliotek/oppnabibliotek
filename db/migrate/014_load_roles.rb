# -*- encoding : utf-8 -*-
class LoadRoles < ActiveRecord::Migration
  def self.up
    reader = Role.create(:name => "Reader")
    reader.save!

    writer = Role.create(:name => "Writer")
    writer.save!

    local_admin = Role.create(:name => "Local Admin")
    local_admin.save!

    admin = Role.create(:name => "Admin")
    admin.save!
end

  def self.down
    Role.delete_all
  end
end
