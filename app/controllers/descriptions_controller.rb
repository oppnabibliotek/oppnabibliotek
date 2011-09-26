# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
class DescriptionsController < ApplicationController
  
  append_before_filter :check_ownership, :only => [:edit, :update, :destroy]
  
  skip_before_filter :check_authentication, :check_authorization, :only => [ :index, :show, :bybookproperty ]
  
  ssl_required :new, :create, :edit, :update, :destroy
  ssl_allowed :index, :show
  
  def check_ownership
    description = find_description(params)

    if (@current_user.admin?)
      # do nothing
    elsif (@current_user.local_admin?)
      description_library_id = description.user.library.id
      user_library_id = @current_user.library.id
      unless description_library_id == user_library_id
        deny_authorization
      end
    elsif (@current_user.writer?)
      description_user_id = description.user.id 
      current_user_id = @current_user.id
      unless description_user_id == current_user_id
        deny_authorization
      end
    else
      #This should never happen
      deny_authorization
    end
  end
  
  # GET /descriptions
  # GET /descriptions.xml
  def index
    set_sort_params(params, params[:description])
    find_descriptions(params)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @descriptions }
      format.atom
    end
  end
  
  # GET /descriptions/1
  # GET /descriptions/1.xml
  def show
    find_description(params)
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @description.to_xml(:include => { :edition => {:include => {:book => {:include => [:keywords, :sb_keywords, :signum]}}}, :user => { :except => [:email, :password_hash], :include => :library } }) }
    end
  end
  
  # GET /descriptions/new
  # GET /descriptions/new.xml
  def new
    @description = Description.new
    @description.edition_id = params[:edition_id]
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @description }
    end
  end
  
  # GET /descriptions/1/edit
  def edit
    @description = Description.find(params[:id])
  end
  
  # POST /descriptions
  # POST /descriptions.xml
  def create
    @description = Description.new(params[:description])
    
    respond_to do |format|
      if @description.save_and_index
        flash[:notice] = 'Description was successfully created.'
        format.html { redirect_to(@description) }
        format.xml  { render :xml => @description, :status => :created, :location => @description }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @description.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /descriptions/1
  # PUT /descriptions/1.xml
  def update
    @description = Description.find(params[:id])
    
    respond_to do |format|
      if @description.update_attributes_and_index(params[:description])
        flash[:notice] = 'Description was successfully updated.'
        format.html { redirect_to(@description) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @description.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /descriptions/1
  # DELETE /descriptions/1.xml
  def destroy
    @description = Description.find(params[:id])
    @description.destroy
    
    respond_to do |format|
      format.html { redirect_to(descriptions_url) }
      format.xml  { head :ok }
    end
  end  
  
  def bybookproperty
    params[:limit] ||= 5
    if params[:property] && params[:value]
      # Line below can probably be written as .joins(:editions => :books)
      #:include => [{:edition => :book}],
      @descriptions = Description.where("books.? = ?", params[:property], params[:value])
	.joins("inner join editions on descriptions.edition_id = editions.id inner join books on editions.book_id = books.id")
	.includes([:edition, {:user => :library}]).order("descriptions.created_at desc").limit(params[:limit]).all
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @descriptions.to_xml(:include => { :edition => { :include => :book }, :user => { :include => :library , :except => [:email, :password_hash]}}) }
    end
  end
  
  private
  
  def find_descriptions(params)
    if !params[:book_id]
      if !params[:edition_id]
        @descriptions = Description.where(params[:description]).limit(params[:limit]).order(params[:order]).offset(params[:offset]).all
      else
        edition = Edition.find(params[:edition_id])
        if edition.nil
          @descriptions = edition.descriptions
        else
          raise "Couldn't find edition"
        end
      end
    else
      book = Book.find(params[:book_id])
      if (book && params[:edition_id])
        edition = book.editions[Integer(params[:edition_id])]
        if edition
          @descriptions = edition.descriptions
        else
          raise "Couldn't find edition"
        end
      end
    end
  end
  
  def find_description(params)
    if !params[:book_id]
      if !params[:edition_id]
        @description = Description.includes(:edition).find(params[:id])
      else
        edition = Edition.find(params[:edition_id])
        if edition.nil
          description = edition.descriptions[Integer(params[:id])]
          if description.nil
            @description = description
          else
            raise "Couldn't find description"
          end
        else
          raise "Couldn't find edition"
        end
      end
    else
      book = Book.find(params[:book_id])
      if (book && params[:edition_id])
        edition = book.editions[Integer(params[:edition_id])]
        if edition
          description = edition.descriptions[Integer(params[:id])]
          if description
            @description = description
          else
            raise "Couldn't find description"
          end
        else
          raise "Couldn't find edition"
        end
      end
    end
  end
  
end
