# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
class TagsController < ApplicationController
  
  skip_before_filter :check_authentication, :check_authorization, :only => [ :index, :show ]
  
  ssl_required :new, :create, :edit, :update, :destroy
  ssl_allowed :index, :show
  
  def check_blacklisting(tag_id)
    
    tag = Tag.find(tag_id)
    
    if @current_user
      blacklistings = tag.blacklistings.find_all {|blacklisting| blacklisting.global || blacklisting.library_id == @current_user.library.id }
    else
      blacklistings = tag.blacklistings
    end
    # Returns true if tag is blacklisted 
    return !blacklistings.empty?
  end
  
  # GET /tags
  # GET /tags.xml
  def index
    
    set_sort_params(params)
    
    if params[:order] && params[:order].eql?("byuse")
      query = "select tags.name, tags.id, count(*) as count from taggings inner join tags on taggings.tag_id = tags.id group by tag_id order by count"
      query += " desc" if !params[:reverse]
      @tags = Tag.find_by_sql(query)
    elsif params[:edition_id] || params[:book_id]
      
      if params[:edition_id]
        sql_where = "where taggings.edition_id = %i" % params[:edition_id] 
      else
        sql_where = "where taggings.book_id = %i" % params[:book_id] 
      end
      
      @tags = Tag.find_by_sql("select tags.name, tags.id, count(*) as count from taggings inner join tags on taggings.tag_id = tags.id " + sql_where + " group by tag_id order by count desc")
      
    else
      @tags = Tag.find(:all, :conditions => params[:tag], :order => params[:order], :limit => params[:limit],
                       :offset => params[:offset])
    end
    
    # Filter out blacklisted tags
    @tags = @tags.find_all { |tag| 
      !check_blacklisting(tag.id)
    }
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags.to_xml(:include => {:books => {}, :editions => {} }) }
    end
    
  end
  
  def count
    
    @tags = Tag.find(:all)
    @total = @tags.size
    @tags = @tags.find_all { |tag| 
      check_blacklisting(tag.id)
    }  
    @blacklisted = @tags.size
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml 
    end
  end
  
  # GET /tags/1
  # GET /tags/1.xml
  def show
    @tag = Tag.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag.to_xml(:include => {:books => {}, :editions => {} }) }
    end
  end
  
  # GET /tags/new
  # GET /tags/new.xml
  def new
    @tag = Tag.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tag }
    end 
  end
  
  # GET /tags/1/edit
  def edit
    @tag = Tag.find(params[:id])
  end
  
  # POST /tags
  # POST /tags.xml
  def create
    
    @tag = Tag.new(params[:tag])
    
    respond_to do |format|
      if @tag.save
        flash[:notice] = 'Tag was successfully created.'
        format.html { redirect_to(@tag) }
        format.xml  { render :xml => @tag, :status => :created, :location => @tag }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /tags/1
  # PUT /tags/1.xml
  def update
    
    @tag = Tag.find(params[:id])
    
    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        flash[:notice] = 'Tag was successfully updated.'
        format.html { redirect_to(@tag) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /tags/1
  # DELETE /tags/1.xml
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy
    
    respond_to do |format|
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end
  
end
