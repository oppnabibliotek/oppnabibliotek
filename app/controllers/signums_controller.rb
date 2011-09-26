# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
class SignumsController < ApplicationController

  skip_before_filter :check_authentication, :check_authorization, :only => [ :index, :show ]

  ssl_required :new, :create, :edit, :update, :destroy
  ssl_allowed :index, :show
  
  # GET /signums
  # GET /signums.xml
  def index
    set_sort_params(params)
    @signums = Signum.find(:all, :conditions => params[:signum], :order => params[:order], :limit => params[:limit],
                                   :offset => params[:offset])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @signums }
    end
  end

  # GET /signums/1
  # GET /signums/1.xml
  def show
    @signum = Signum.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @signum }
    end
  end

  # GET /signums/new
  # GET /signums/new.xml
  def new
    @signum = Signum.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @signum }
    end
  end

  # GET /signums/1/edit
  def edit
    @signum = Signum.find(params[:id])
  end

  # POST /signums
  # POST /signums.xml
  def create
    @signum = Signum.new(params[:signum])

    respond_to do |format|
      if @signum.save
        flash[:notice] = 'Signum was successfully created.'
        format.html { redirect_to(@signum) }
        format.xml  { render :xml => @signum, :status => :created, :location => @signum }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @signum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /signums/1
  # PUT /signums/1.xml
  def update
    @signum = Signum.find(params[:id])

    respond_to do |format|
      if @signum.update_attributes(params[:signum])
        flash[:notice] = 'Signum was successfully updated.'
        format.html { redirect_to(@signum) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @signum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /signums/1
  # DELETE /signums/1.xml
  def destroy
    @signum = Signum.find(params[:id])
    @signum.destroy

    respond_to do |format|
      format.html { redirect_to(signums_url) }
      format.xml  { head :ok }
    end
  end
end
