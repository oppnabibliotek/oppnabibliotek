# -*- encoding : utf-8 -*-
class ModifySbKeywords < ActiveRecord::Migration
  def self.up
    add_column :sb_keywords, :namecode, :string
  end
  
  def self.down
    remove_column :sb_keywords, :namecode
  end
end
