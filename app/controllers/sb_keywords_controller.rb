# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
class SbKeywordsController < ApplicationController

  skip_before_filter :check_authentication, :check_authorization, :only => [ :index, :show ]
  
  ssl_required :new, :create, :edit, :update, :destroy
  ssl_allowed :index, :show
  
  # GET /sb_keywords
  # GET /sb_keywords.xml
  def index
    set_sort_params(params)
    @sb_keywords = SbKeyword.where(params[:sb_keyword]).order(params[:order]).limit(params[:limit]).offset(params[:offset])
    #@sb_keywords = SbKeyword.find(:all, :conditions => params[:sb_keyword], :order => params[:order], :limit => params[:limit],
    #                               :offset => params[:offset])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sb_keywords }
    end
  end

  # GET /sb_keywords/1
  # GET /sb_keywords/1.xml
  def show
    @sb_keyword = SbKeyword.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sb_keyword }
    end
  end

  # GET /sb_keywords/new
  # GET /sb_keywords/new.xml
  def new
    @sb_keyword = SbKeyword.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sb_keyword }
    end
  end

  # GET /sb_keywords/1/edit
  def edit
    @sb_keyword = SbKeyword.find(params[:id])
  end

  # POST /sb_keywords
  # POST /sb_keywords.xml
  def create
    @sb_keyword = SbKeyword.new(params[:sb_keyword])

    respond_to do |format|
      if @sb_keyword.save
        flash[:notice] = 'SbKeyword was successfully created.'
        format.html { redirect_to(@sb_keyword) }
        format.xml  { render :xml => @sb_keyword, :status => :created, :location => @sb_keyword }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sb_keyword.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sb_keywords/1
  # PUT /sb_keywords/1.xml
  def update
    @sb_keyword = SbKeyword.find(params[:id])

    respond_to do |format|
      if @sb_keyword.update_attributes(params[:sb_keyword])
        flash[:notice] = 'SbKeyword was successfully updated.'
        format.html { redirect_to(@sb_keyword) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sb_keyword.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sb_keywords/1
  # DELETE /sb_keywords/1.xml
  def destroy
    @sb_keyword = SbKeyword.find(params[:id])
    @sb_keyword.destroy

    respond_to do |format|
      format.html { redirect_to(sb_keywords_url) }
      format.xml  { head :ok }
    end
  end
end
