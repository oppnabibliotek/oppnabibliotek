# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
class CountiesController < ApplicationController

  skip_before_filter :check_authentication, :check_authorization, :only => [ :index, :show ]
  
  ssl_required :new, :create, :edit, :update, :destroy
  ssl_allowed :index, :show
  
  # GET /counties
  # GET /counties.xml
  def index
    set_sort_params(params)
    @counties = County.find(:all, :conditions => params[:county], :limit => params[:limit], :order => params[:order], 
                                   :offset => params[:offset])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @counties }
    end
  end

  # GET /counties/1
  # GET /counties/1.xml
  def show
    @county = County.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
     # format.xml  { render :xml => @county }
       format.xml  { render :xml => @county.to_xml(:include => { :libraries => { :include => :departments } }) }
    end
  end

  # GET /counties/new
  # GET /counties/new.xml
  def new
    @county = County.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @county }
    end
  end

  # GET /counties/1/edit
  def edit
    @county = County.find(params[:id])
  end

  # POST /counties
  # POST /counties.xml
  def create
    @county = County.new(params[:county])

    respond_to do |format|
      if @county.save
        flash[:notice] = 'County was successfully created.'
        format.html { redirect_to(@county) }
        format.xml  { render :xml => @county, :status => :created, :location => @county }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @county.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /counties/1
  # PUT /counties/1.xml
  def update
    @county = County.find(params[:id])

    respond_to do |format|
      if @county.update_attributes(params[:county])
        flash[:notice] = 'County was successfully updated.'
        format.html { redirect_to(@county) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @county.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /counties/1
  # DELETE /counties/1.xml
  def destroy
    @county = County.find(params[:id])
    @county.destroy

    respond_to do |format|
      format.html { redirect_to(counties_url) }
      format.xml  { head :ok }
    end
  end
end
