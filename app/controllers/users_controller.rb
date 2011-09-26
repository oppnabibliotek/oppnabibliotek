# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
class UsersController < ApplicationController

  class UserNotFoundException < StandardError
  end  

  append_before_filter :check_permissions, :only => [:byusername, :show, :create, :edit, :update, :destroy]
  
  ssl_required :byusername, :new, :create, :edit, :update, :destroy, :search
  ssl_allowed :index, :show, :usersearch
  
  rescue_from UserNotFoundException, :with => :user_not_found

  def user_not_found
    respond_to do |format|
      format.xml  { render :xml => create_error_message_xml("User not found"), :status => :unprocessable_entity}
    end
  end

  def check_permissions
    if (@current_user.admin?)
      # do nothing
    elsif (@current_user.local_admin?)
      if params[:action] == "create"
        edited_user = User.new(params[:user])
      elsif params[:action] == "byusername"
        edited_user = User.where('username = ?' , params[:username]).first
      else
        edited_user = find_user(params)
      end
      if !edited_user
        raise UserNotFoundException
      end
      edited_user_library = edited_user.library
      edited_user_library_id = edited_user_library.id 
      current_user_library_id = @current_user.library.id
      unless edited_user_library_id == current_user_library_id
        deny_authorization
      end
    elsif (@current_user.writer? || @current_user.member?)
      if params[:action] == "byusername"
        edited_user = User.where('username = ?' , params[:username]).first
      else
        edited_user = find_user(params)
      end
      if !edited_user
        raise UserNotFoundException
      end
      unless edited_user.username == @current_user.username
        deny_authorization
      end
    else
      deny_authorization
    end
  end
  
  def check_permissions_for_setting_roles
    admin = Role.admin

    # User is admin, return
    if @current_user.roles.include?(admin)
      return true
    end
    
    input_roles = []
    role_ids = params[:user][:role_ids]
    if role_ids
      role_ids.each { |role_id|
        input_roles << Role.find(role_id)
      }
    else
      # roles are not updated
      return true
    end
    
    
    if params[:action] == "create" && input_roles.include?(admin)
      # Non-admin tries to create an admin user, deny
      return false
    elsif params[:action] == "update"
      edited_user = find_user(params) 
      if edited_user.roles == input_roles
        # Roles have not been updated
        return true
      elsif !@current_user.local_admin? && !@current_user.roles.include?(admin)
        # Non-admin and non-local admin user tries to update roles, deny
        return false
      elsif input_roles.include?(admin)
        # Local admin tries to update user to admin, deny
        return false
      else
        return true
      end
    else
      return true
    end
    
  end
  
  def filter_return_content
    if @current_user.admin?
      # do nothing
    elsif @current_user.local_admin?
      @users.each{|edited_user|
        edited_user_library_id = edited_user.library.id 
        current_user_library_id = @current_user.library.id
        unless edited_user_library_id == current_user_library_id
          edited_user.email = nil
        end
      }
    else
      # Shold never happen
      @users = nil
    end
  end
  
  # GET /users
  # GET /users.xml
  def index
    set_sort_params(params)
    
    respond_to do |format|
      format.html {
        @users = User.order("username").page(params[:page])
        filter_return_content
      }
      format.xml  { 
        if params[:order] && params[:order].index("activity") == 0
          if params[:order].index("activity_assessments") == 0
            sql_where_total = get_sql_where_statements(params[:user], "a", true)
            query = "select u.*, count(*) as user_assessments from users u " +
              "inner join assessments a on u.id = a.user_id inner join libraries l on u.library_id = l.id " +
              "inner join counties c on l.county_id = c.id " + sql_where_total + " group by u.id order by count(*)"
          elsif params[:order].index("activity_grades") == 0
            sql_where_total = get_sql_where_statements(params[:user], "a", true)
            query = "select u.*, avg(a.grade) as grade_average from users u " +
              "inner join assessments a on u.id = a.user_id inner join libraries l on u.library_id = l.id " +
              "inner join counties c on l.county_id = c.id " + sql_where_total + " group by u.id order by avg(a.grade)"
          elsif params[:order].index("activity_taggings") == 0
            sql_where_total = get_sql_where_statements(params[:user], "t", true)
            query = "select u.*, count(*) as user_taggings from users u " +
              "inner join taggings t on u.id = t.user_id inner join libraries l on u.library_id = l.id " +
              "inner join counties c on l.county_id = c.id " + sql_where_total + " group by u.id order by count(*)"
          end
          query += " desc" if !params[:reverse]
          @users = User.find_by_sql(query)
        else
          @users = User.where(params[:user]).order(params[:order]).limit(params[:limit]).offset(params[:offset])
        end
        @users ||= []
        filter_return_content
        render :xml => @users.to_xml(:except => :password_hash)
      }
    end
  end

  # GET  /users/usersearch
  # POST /users/usersearch
  def usersearch
    respond_to do |format|
      format.html {
        @users = User.order('username').page(params[:page]).per(10)
        unless params[:usersearch].blank?
          p = "%#{params[:usersearch]}%"
          @users = @users.where("username like ? or firstname like ? or lastname like ? or email like ?", p, p, p, p)
        end
        if request.get?
          render :action => :index
        else
          render :partial=>'shared/usersearch', :layout=>false
        end
      }
    end
  end
  
  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user.to_xml(:include => { :library => {}, :roles => {} }, :except => :password_hash) }
    end
  end
  
  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end
  
  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end
  
  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    if check_permissions_for_setting_roles
      respond_to do |format|
        if @user.save
          format.html { redirect_to(@user, :notice => 'User was successfully created.') }
          format.xml  { render :xml => @user, :status => :created, :location => @user }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    else
      respond_to { |format|
        format.html { render :action => "new" }
        format.xml { deny_authorization }
      }
    end
  end
  
  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    if check_permissions_for_setting_roles
      respond_to do |format|
        if @user.update_attributes(params[:user])
          format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    else
      respond_to { |format|
        format.html { render :action => "edit" }
        format.xml { deny_authorization }
      }
    end
  end
  
  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    
    respond_to do |format|
      format.html { redirect_to :controller => :users, :action => :usersearch} #, :protocol => 'https', :only_path => false}
      format.xml  { head :ok }
    end
  end
  
  def byusername
    @user = User.where('username = ?' , params[:username]).first
    if !@user
      raise UserNotFoundException
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user.to_xml(:skip_types => true, :include => [:library, :roles] , :except => :password_hash) }
    end
  end
  
  def dbdump
    infile = File.new("dumps/mysqldump.sql.zip", "r")
    file_data = infile.gets(nil)
    
    respond_to do |format|
      format.html { raise "Please access through dbdump.xml or by setting accept to text/xml" }
      format.xml  { send_data file_data, :type => "application/zip", :filename=>"mysqldump.sql.zip" }
    end
  end

  private
  
  def find_user(params)
    if !params[:library_id]
      user = User.find(params[:id])
      if user
        @user = user
      else
        raise UserNotFoundException
      end
    else
      library = Library.find(params[:library_id])
      if library
        user = library.users[Integer(params[:id])]
        if user
          @user = user
        else
          raise UserNotFoundException
        end
      end
    end
  end
end
