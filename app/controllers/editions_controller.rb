# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
class EditionsController < ApplicationController
  
  #append_before_filter :check_published, :only => [:show]
  
  skip_before_filter :check_authentication, :check_authorization, :only => [ :index, :show ]
  
  ssl_required :new, :create, :edit, :update, :destroy
  ssl_allowed :index, :show
  
  def check_published
    edition = find_edition(params)
    if !edition.published?
      check_authentication
      unless @current_user && @current_user.moreThanMember?
        deny_authorization
      end
    end
  end
  
  
  # GET /editions
  # GET /editions.xml
  def index
    set_sort_params(params, params[:edition])
    find_editions(params)
    
    #exclude_unpublished
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @editions }
      format.atom
    end
  end
  
  # GET /editions/1
  # GET /editions/1.xml
  def show
    find_edition(params)
    if !@edition.imageurl && @edition.image
      @edition.imageurl = @edition.image.public_filename
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @edition.to_xml(:include => [:image, :descriptions]) }
    end
  end
  
  # GET /editions/new
  # GET /editions/new.xml
  def new
    @edition = Edition.new
    @edition.book_id = params[:book_id]
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @edition }
    end
  end
  
  # GET /editions/1/edit
  def edit
    @edition = Edition.find(params[:id])
  end
  
  # POST /editions
  # POST /editions.xml
  def create
    
    params[:edition] = {} if !params[:edition]
    params[:edition][:isbn] = format_isbn(params[:edition][:isbn]) if params[:edition][:isbn]
    
    @edition = Edition.new(params[:edition])
    
    respond_to do |format|
      if @edition.save_with_image_and_index
        format.html { redirect_to(@edition, :notice => 'Edition was successfully created.') }
        format.xml  { render :xml => @edition, :status => :created, :location => @edition }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @edition.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /editions/1
  # PUT /editions/1.xml
  def update
    
    params[:edition] = {} if !params[:edition]
    params[:edition][:isbn] = format_isbn(params[:edition][:isbn]) if params[:edition][:isbn]
    
    @edition = Edition.find(params[:id])
    
    respond_to do |format|
      if @edition.update_attributes_and_index(params[:edition])
        format.html { redirect_to(@edition, :notice => 'Edition was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @edition.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /editions/1
  # DELETE /editions/1.xml
  def destroy
    @edition = Edition.find(params[:id])
    @edition.destroy
    
    respond_to do |format|
      format.html { redirect_to(editions_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def find_editions(params)
    if !params[:book_id]
      
      params[:edition] = {} if !params[:edition]
      params[:edition][:isbn] = format_isbn(params[:edition][:isbn]) if params[:edition][:isbn]
    
      @editions = Edition.find(:all, :conditions => params[:edition], :limit => params[:limit], :order => params[:order], 
                               :offset => params[:offset])
    else
      book = Book.find(params[:book_id])
      @editions = book.editions if book
    end
  end
  
  def find_edition(params)
    if !params[:book_id]
      @edition = Edition.find(params[:id])
    else
      book = Book.find(params[:book_id])
      if book
        edition = book.editions[Integer(params[:id])]
        if edition
          @edition = edition 
        else
          raise "Couldn't find edition"
        end
      end
    end
  end
  
end
