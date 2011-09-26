# -*- encoding : utf-8 -*-
class LoadRights < ActiveRecord::Migration
  def self.up
    writer = Role.find(:first, :conditions => [ "name = ?", "Writer"])
    local_admin = Role.find(:first, :conditions => [ "name = ?", "Local Admin"])
    admin = Role.find(:first, :conditions => [ "name = ?", "Admin"])
    
    show_user = Right.create(:name => "Show user", :controller => "users", :action => "show")
    show_user.roles << local_admin
    show_user.roles << admin
    show_users = Right.create(:name => "Show users", :controller => "users", :action => "index")
    show_users.roles << local_admin
    show_users.roles << admin
    new_user = Right.create(:name => "New user", :controller => "users", :action => "new")
    new_user.roles << local_admin
    new_user.roles << admin
    create_user = Right.create(:name => "Create User", :controller => "users", :action => "create")
    create_user.roles << local_admin
    create_user.roles << admin
    edit_user = Right.create(:name => "Edit User", :controller => "users", :action => "edit")
    edit_user.roles << local_admin
    edit_user.roles << admin
    update_user = Right.create(:name => "Update User", :controller => "users", :action => "update")
    update_user.roles << local_admin
    update_user.roles << admin
    destroy_user = Right.create(:name => "Destroy User", :controller => "users", :action => "destroy")
    destroy_user.roles << local_admin
    destroy_user.roles << admin

    new_book = Right.create(:name => "New Book", :controller => "books", :action => "new")
    new_book.roles << writer
    new_book.roles << local_admin
    new_book.roles << admin
    create_book = Right.create(:name => "Create Book", :controller => "books", :action => "create")
    create_book.roles << writer
    create_book.roles << local_admin
    create_book.roles << admin
    edit_book = Right.create(:name => "Edit Book", :controller => "books", :action => "edit")
    edit_book.roles << writer
    edit_book.roles << local_admin
    edit_book.roles << admin
    update_book = Right.create(:name => "Update Book", :controller => "books", :action => "update")
    update_book.roles << writer
    update_book.roles << local_admin
    update_book.roles << admin
    destroy_book = Right.create(:name => "Destroy Book", :controller => "books", :action => "destroy")
    #destroy_book.roles << writer
    destroy_book.roles << local_admin
    destroy_book.roles << admin

    new_edition = Right.create(:name => "New edition", :controller => "editions", :action => "new")
    new_edition.roles << writer
    new_edition.roles << local_admin
    new_edition.roles << admin
    create_edition = Right.create(:name => "Create Edition", :controller => "editions", :action => "create")
    create_edition.roles << writer
    create_edition.roles << local_admin
    create_edition.roles << admin
    edit_edition = Right.create(:name => "Edit Edition", :controller => "editions", :action => "edit")
    edit_edition.roles << writer
    edit_edition.roles << local_admin
    edit_edition.roles << admin
    update_edition = Right.create(:name => "Update Edition", :controller => "editions", :action => "update")
    update_edition.roles << writer
    update_edition.roles << local_admin
    update_edition.roles << admin
    destroy_edition = Right.create(:name => "Destroy Edition", :controller => "editions", :action => "destroy")
    #destroy_edition.roles << writer
    destroy_edition.roles << local_admin
    destroy_edition.roles << admin

    new_description = Right.create(:name => "New description", :controller => "descriptions", :action => "new")
    new_description.roles << writer
    new_description.roles << local_admin
    new_description.roles << admin
    create_description = Right.create(:name => "Create Description", :controller => "descriptions", :action => "create")
    create_description.roles << writer
    create_description.roles << local_admin
    create_description.roles << admin
    edit_description = Right.create(:name => "Edit Description", :controller => "descriptions", :action => "edit")
    edit_description.roles << writer
    edit_description.roles << local_admin
    edit_description.roles << admin
    update_description = Right.create(:name => "Update Description", :controller => "descriptions", :action => "update")
    update_description.roles << writer
    update_description.roles << local_admin
    update_description.roles << admin
    destroy_description = Right.create(:name => "Destroy Description", :controller => "descriptions", :action => "destroy")
    destroy_description.roles << writer
    destroy_description.roles << local_admin
    destroy_description.roles << admin

    new_library = Right.create(:name => "New Library", :controller => "libraries", :action => "new")
    new_library.roles << admin
    create_library = Right.create(:name => "Create Library", :controller => "libraries", :action => "create")
    create_library.roles << admin
    edit_library = Right.create(:name => "Edit Library", :controller => "libraries", :action => "edit")
    edit_library.roles << local_admin
    edit_library.roles << admin
    update_library = Right.create(:name => "Update Library", :controller => "libraries", :action => "update")
    update_library.roles << local_admin
    update_library.roles << admin
    destroy_library = Right.create(:name => "Destroy Library", :controller => "libraries", :action => "destroy")
    destroy_library.roles << admin

    new_county = Right.create(:name => "New County", :controller => "counties", :action => "new")
    new_county.roles << admin
    create_county = Right.create(:name => "Create County", :controller => "counties", :action => "create")
    create_county.roles << admin
    edit_county = Right.create(:name => "Edit County", :controller => "counties", :action => "edit")
    edit_county.roles << admin
    update_county = Right.create(:name => "Update County", :controller => "counties", :action => "update")
    update_county.roles << admin
    destroy_county = Right.create(:name => "Destroy County", :controller => "counties", :action => "destroy")
    destroy_county.roles << admin

    new_department = Right.create(:name => "New Department", :controller => "departments", :action => "new")
    new_department.roles << local_admin
    new_department.roles << admin
    create_department = Right.create(:name => "Create Department", :controller => "departments", :action => "create")
    create_department.roles << local_admin
    create_department.roles << admin
    edit_department = Right.create(:name => "Edit Department", :controller => "departments", :action => "edit")
    edit_department.roles << local_admin
    edit_department.roles << admin
    update_department = Right.create(:name => "Update Department", :controller => "departments", :action => "update")
    update_department.roles << local_admin
    update_department.roles << admin
    destroy_department = Right.create(:name => "Destroy Department", :controller => "departments", :action => "destroy")
    destroy_department.roles << local_admin
    destroy_department.roles << admin

    new_keyword = Right.create(:name => "New Keyword", :controller => "keywords", :action => "new")
    new_keyword.roles << writer
    new_keyword.roles << local_admin
    new_keyword.roles << admin
    create_keyword = Right.create(:name => "Create Keyword", :controller => "keywords", :action => "create")
    create_keyword.roles << writer
    create_keyword.roles << local_admin
    create_keyword.roles << admin
    edit_keyword = Right.create(:name => "Edit Keyword", :controller => "keywords", :action => "edit")
    edit_keyword.roles << writer
    edit_keyword.roles << local_admin
    edit_keyword.roles << admin
    update_keyword = Right.create(:name => "Update Keyword", :controller => "keywords", :action => "update")
    update_keyword.roles << writer
    update_keyword.roles << local_admin
    update_keyword.roles << admin
    destroy_keyword = Right.create(:name => "Destroy Keyword", :controller => "keywords", :action => "destroy")
    destroy_keyword.roles << writer
    destroy_keyword.roles << local_admin
    destroy_keyword.roles << admin

    new_sb_keyword = Right.create(:name => "New SB Keyword", :controller => "sb_keywords", :action => "new")
    new_sb_keyword.roles << writer
    new_sb_keyword.roles << local_admin
    new_sb_keyword.roles << admin
    create_sb_keyword = Right.create(:name => "Create SB Keyword", :controller => "sb_keywords", :action => "create")
    create_sb_keyword.roles << writer
    create_sb_keyword.roles << local_admin
    create_sb_keyword.roles << admin
    edit_sb_keyword = Right.create(:name => "Edit SB Keyword", :controller => "sb_keywords", :action => "edit")
    edit_sb_keyword.roles << writer
    edit_sb_keyword.roles << local_admin
    edit_sb_keyword.roles << admin
    update_sb_keyword = Right.create(:name => "Update SB Keyword", :controller => "sb_keywords", :action => "update")
    update_sb_keyword.roles << writer
    update_sb_keyword.roles << local_admin
    update_sb_keyword.roles << admin
    destroy_sb_keyword = Right.create(:name => "Destroy SB Keyword", :controller => "sb_keywords", :action => "destroy")
    destroy_sb_keyword.roles << writer
    destroy_sb_keyword.roles << local_admin
    destroy_sb_keyword.roles << admin

    new_signum = Right.create(:name => "New Signum", :controller => "signums", :action => "new")
    new_signum.roles << writer
    new_signum.roles << local_admin
    new_signum.roles << admin
    create_signum = Right.create(:name => "Create Signum", :controller => "signums", :action => "create")
    create_signum.roles << writer
    create_signum.roles << local_admin
    create_signum.roles << admin
    edit_signum = Right.create(:name => "Edit Signum", :controller => "signums", :action => "edit")
    edit_signum.roles << writer
    edit_signum.roles << local_admin
    edit_signum.roles << admin
    update_signum = Right.create(:name => "Update Signum", :controller => "signums", :action => "update")
    update_signum.roles << writer
    update_signum.roles << local_admin
    update_signum.roles << admin
    destroy_signum = Right.create(:name => "Destroy Signum", :controller => "signums", :action => "destroy")
    destroy_signum.roles << writer
    destroy_signum.roles << local_admin
    destroy_signum.roles << admin
  end

  def self.down
    Right.delete_all
  end

end
