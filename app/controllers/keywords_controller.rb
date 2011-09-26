# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
class KeywordsController < ApplicationController

  skip_before_filter :check_authentication, :check_authorization, :only => [ :index, :show ]
  
  ssl_required :new, :create, :edit, :update, :destroy
  ssl_allowed :index, :show

  # GET /keywords
  # GET /keywords.xml
  def index
    set_sort_params(params)
    if params[:order] && params[:order].eql?("byuse")
      #sql_offset = "offset " + params[:offset] if params[:offset]
      #sql_limit = "limit " + params[:limit] if params[:limit]
      #sql_reverse = "desc" #params[:reverse] ? "ASC" : "DESC"
      @keywords = Keyword.find_by_sql("SELECT k.name, COUNT(1) count FROM keywords k INNER JOIN books_keywords bk ON k.id = bk.keyword_id GROUP BY k.name ORDER BY COUNT(1) DESC") # %s %s %s" % [sql_reverse, sql_limit, sql_offset])
    else
      @keywords = Keyword.find(:all, :conditions => params[:keyword], :order => params[:order], :limit => params[:limit],
                                   :offset => params[:offset])
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @keywords }
    end
  end

  # GET /keywords/1
  # GET /keywords/1.xml
  def show
    @keyword = Keyword.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @keyword }
    end
  end

  # GET /keywords/new
  # GET /keywords/new.xml
  def new
    @keyword = Keyword.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @keyword }
    end
  end

  # GET /keywords/1/edit
  def edit
    @keyword = Keyword.find(params[:id])
  end

  # POST /keywords
  # POST /keywords.xml
  def create
    @keyword = Keyword.new(params[:keyword])

    respond_to do |format|
      if @keyword.save
        flash[:notice] = 'Keyword was successfully created.'
        format.html { redirect_to(@keyword) }
        format.xml  { render :xml => @keyword, :status => :created, :location => @keyword }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @keyword.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /keywords/1
  # PUT /keywords/1.xml
  def update
    @keyword = Keyword.find(params[:id])

    respond_to do |format|
      if @keyword.update_attributes(params[:keyword])
        flash[:notice] = 'Keyword was successfully updated.'
        format.html { redirect_to(@keyword) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @keyword.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /keywords/1
  # DELETE /keywords/1.xml
  def destroy
    @keyword = Keyword.find(params[:id])
    @keyword.destroy

    respond_to do |format|
      format.html { redirect_to(keywords_url) }
      format.xml  { head :ok }
    end
  end
end
