# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
class TargetgroupsController < ApplicationController

  skip_before_filter :check_authentication, :check_authorization, :only => [ :index, :show ]
  
  ssl_required :new, :create, :edit, :update, :destroy
  ssl_allowed :index, :show
  
  # GET /targetgroups
  # GET /targetgroups.xml
  def index
    set_sort_params(params)
    @targetgroups = Targetgroup.find(:all, params[:targetgroup], :order => params[:order], :limit => params[:limit],
                                   :offset => params[:offset])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @targetgroups }
    end
  end

  # GET /targetgroups/1
  # GET /targetgroups/1.xml
  def show
    @targetgroup = Targetgroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @targetgroup }
    end
  end

  # GET /targetgroups/new
  # GET /targetgroups/new.xml
  def new
    @targetgroup = Targetgroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @targetgroup }
    end
  end

  # GET /targetgroups/1/edit
  def edit
    @targetgroup = Targetgroup.find(params[:id])
  end

  # POST /targetgroups
  # POST /targetgroups.xml
  def create
    @targetgroup = Targetgroup.new(params[:targetgroup])

    respond_to do |format|
      if @targetgroup.save
        flash[:notice] = 'Targetgroup was successfully created.'
        format.html { redirect_to(@targetgroup) }
        format.xml  { render :xml => @targetgroup, :status => :created, :location => @targetgroup }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @targetgroup.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /targetgroups/1
  # PUT /targetgroups/1.xml
  def update
    @targetgroup = Targetgroup.find(params[:id])

    respond_to do |format|
      if @targetgroup.update_attributes(params[:targetgroup])
        flash[:notice] = 'Targetgroup was successfully updated.'
        format.html { redirect_to(@targetgroup) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @targetgroup.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /targetgroups/1
  # DELETE /targetgroups/1.xml
  def destroy
    @targetgroup = Targetgroup.find(params[:id])
    @targetgroup.destroy

    respond_to do |format|
      format.html { redirect_to(targetgroups_url) }
      format.xml  { head :ok }
    end
  end
end
