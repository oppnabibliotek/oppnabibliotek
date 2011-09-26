# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
class DepartmentsController < ApplicationController

  skip_before_filter :check_authentication, :check_authorization, :only => [ :index, :show ]

  append_before_filter :check_permissions, :only => [:edit, :update, :destroy]
  
  ssl_required :new, :create, :edit, :update, :destroy
  ssl_allowed :index, :show

  def check_permissions
    if (@current_user.admin?)
      # do nothing
    elsif (@current_user.local_admin?)
      edited_department = find_department(params)
      edited_department_library_id = edited_department.library.id 
      current_department_library_id = @current_user.library.id
      unless edited_department_library_id == current_department_library_id
        deny_authorization
      end
    else
      deny_authorization
    end
  end
  
  # GET /departments
  # GET /departments.xml
  def index
    set_sort_params(params)
    @departments = Department.where(params[:county]).limit(params[:limit]).order(params[:order]).offset(params[:offset])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @departments }
    end
  end

  # GET /departments/1
  # GET /departments/1.xml
  def show
    @department = Department.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @department.to_xml }
    end
  end

  # GET /departments/new
  # GET /departments/new.xml
  def new
    @department = Department.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @department }
    end
  end

  # GET /departments/1/edit
  def edit
    @department = Department.find(params[:id])
  end

  # POST /departments
  # POST /departments.xml
  def create
    @department = Department.new(params[:department])

    respond_to do |format|
      if @department.save
        format.html { redirect_to(@department, :notice => 'Department was successfully created.') }
        format.xml  { render :xml => @department, :status => :created, :location => @department }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @department.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /departments/1
  # PUT /departments/1.xml
  def update
    @department = Department.find(params[:id])

    respond_to do |format|
      if @department.update_attributes(params[:department])
        format.html { redirect_to(@department, :notice => 'Department was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @department.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /departments/1
  # DELETE /departments/1.xml
  def destroy
    @department = Department.find(params[:id])
    @department.destroy

    respond_to do |format|
      format.html { redirect_to(departments_url) }
      format.xml  { head :ok }
    end
  end
end
