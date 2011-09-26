# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
class AgegroupsController < ApplicationController
  
  skip_before_filter :check_authentication, :check_authorization, :only => [ :index, :show ]

  ssl_required :new, :create, :edit, :update, :destroy
  ssl_allowed :index, :show
  
  # GET /agegroups
  # GET /agegroups.xml
  def index
    
    set_sort_params(params)
    @agegroups = Agegroup.find(:all, :conditions => params[:agegroup], :limit => params[:limit], :order => params[:order], 
                                   :offset => params[:offset])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @agegroups }
    end
  end

  # GET /agegroups/1
  # GET /agegroups/1.xml
  def show
    @agegroup = Agegroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @agegroup }
    end
  end

  # GET /agegroups/new
  # GET /agegroups/new.xml
  def new
    @agegroup = Agegroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @agegroup }
    end
  end

  # GET /agegroups/1/edit
  def edit
    @agegroup = Agegroup.find(params[:id])
  end

  # POST /agegroups
  # POST /agegroups.xml
  def create
    @agegroup = Agegroup.new(params[:agegroup])

    respond_to do |format|
      if @agegroup.save
        flash[:notice] = 'Agegroup was successfully created.'
        format.html { redirect_to(@agegroup) }
        format.xml  { render :xml => @agegroup, :status => :created, :location => @agegroup }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @agegroup.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /agegroups/1
  # PUT /agegroups/1.xml
  def update
    @agegroup = Agegroup.find(params[:id])

    respond_to do |format|
      if @agegroup.update_attributes(params[:agegroup])
        flash[:notice] = 'Agegroup was successfully updated.'
        format.html { redirect_to(@agegroup) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @agegroup.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /agegroups/1
  # DELETE /agegroups/1.xml
  def destroy
    @agegroup = Agegroup.find(params[:id])
    @agegroup.destroy

    respond_to do |format|
      format.html { redirect_to(agegroups_url) }
      format.xml  { head :ok }
    end
  end
end
