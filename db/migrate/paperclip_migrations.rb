# -*- encoding : utf-8 -*-
module PaperclipMigrations

  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def add_paperclip_fields(table, prefix)
      add_column table, "#{prefix}_file_name", :string
      add_column table, "#{prefix}_content_type", :string
      add_column table, "#{prefix}_file_size", :integer
      add_column table, "#{prefix}_updated_at", :datetime
    end
  
    def populate_paperclip_from_attachment_fu(model, attachment, prefix)
      unless attachment.filename.nil?
        model.send("#{prefix}_file_name=", attachment.filename)
        model.send("#{prefix}_content_type=", attachment.content_type)
        model.send("#{prefix}_file_size=", attachment.size)
    
        old_path = File.join(RAILS_ROOT, 'public', attachment.public_filename)
        new_path = model.send(prefix).path(:original)
        new_folder = File.dirname(new_path)
      
        unless File.exists?(new_folder)
          FileUtils.mkdir_p(new_folder)
        end
      
        if File.exists?(old_path)
          puts "Moving #{old_path} to #{new_path}"
          File.copy(old_path, new_path)
          model.save
          model.send(prefix).reprocess!
        else
          puts "No such file: #{old_path}"
        end
      end
    end
  end
end
