# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
class LibrariesController < ApplicationController
  
  layout "users"
  
  skip_before_filter :check_authentication, :check_authorization, :only => [ :index, :show, :dynurl ]
  
  #append_before_filter :check_optional_authentication, :only => [:show]
  append_before_filter :check_permissions, :only => [:edit, :update, :destroy]
  
  ssl_required :new, :create, :edit, :update, :destroy
  ssl_allowed :index, :show, :dynurl, :librarysearch
  
  def check_permissions
    if !@current_user
      deny_authorization
    elsif (@current_user.admin?)
      # do nothing
    elsif (@current_user.local_admin?)
      edited_library = find_library(params)
      edited_library_id = edited_library.id 
      current_user_library_id = @current_user.library.id
      unless edited_library_id == current_user_library_id
        deny_authorization
      end
    else
      deny_authorization
    end
  end
  
  # GET /libraries
  # GET /libraries.xml
  def index
    if params[:order] && params[:order].eql?("bydescriptions")
      @libraries = Library.find_by_sql("select l.name, l.id, count(d.id) count from libraries l inner join users u on u.library_id = l.id inner join descriptions d on d.user_id = u.id group by l.name, l.id order by count(d.id) desc")
    else
      set_sort_params(params)
      find_libraries(params)
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @libraries.to_xml(:except => :dev_key) }
    end
  end
  
  # GET  /libraries/librarysearch
  # POST /libraries/librarysearch
  def librarysearch
    respond_to do |format|
      format.html {
        @libraries = Library.order('name').page(params[:page]).per(30)
        unless params[:librarysearch].blank?
          @libraries = @libraries.where("name like ?", "%#{params[:librarysearch]}%")
        end
        if request.get?
          render :action => :index
        else
          render :partial=>'shared/librarysearch', :layout=>false
        end
      }
    end
  end
  
  # GET /libraries/1
  # GET /libraries/1.xml
  def show
    @library = Library.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @library.to_xml(:include => :county) }
    end
  end
  
  # GET /libraries/new
  # GET /libraries/new.xml
  def new
    @library = Library.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @library }
    end
  end
  
  # GET /libraries/1/edit
  def edit
    @library = Library.find(params[:id])
  end
  
  # POST /libraries
  # POST /libraries.xml
  def create
    @library = Library.new(params[:library])
    
    respond_to do |format|
      if @library.save
        flash[:notice] = 'Library was successfully created.'
        format.html { redirect_to(@library) }
        format.xml  { render :xml => @library, :status => :created, :location => @library }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @library.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /libraries/1
  # PUT /libraries/1.xml
  def update
    @library = Library.find(params[:id])
    
    respond_to do |format|
      if @library.update_attributes(params[:library])
        flash[:notice] = 'Library was successfully updated.'
        format.html { redirect_to(@library) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @library.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /libraries/1
  # DELETE /libraries/1.xml
  def destroy
    @library = Library.find(params[:id])
    @library.destroy
    
    respond_to do |format|
      format.html {redirect_to :controller => :libraries, :action => :librarysearch}
      format.xml  { head :ok }
    end
  end
  
  def dynurl
    library = Library.find(params[:id])
    edition = Edition.find(params[:edition_id])
    mydynurl = library.bookinfolink
    mydynurl = mydynurl.gsub("TERM1", edition.book.title) if edition.book
    mydynurl = mydynurl.gsub("TERM2", edition.book.authorfirstname + " " + edition.book.authorlastname) if edition.book
    mydynurl = mydynurl.gsub("TERM3", edition.isbn)
    @dynurl = mydynurl
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @library }
    end
  end
  
  private
  
  def find_libraries(params)
    if !params[:county_id]
      @libraries = Library.where(params[:library]).order(params[:order]).page(params[:page])
    else
      county = County.find(params[:county_id])
      @libraries = county.libraries if county
      @libraries.sort!{|lib1, lib2| lib1.name <=> lib2.name} if params[:order]
    end
  end
  
  def find_library(params)
    if !params[:county_id]
      @library = Library.find(params[:id])
    else
      county = County.find(params[:county_id])
      if county
        library = county.libraries[Integer(params[:id])]
        if library
          @library = library 
        else
          raise "Couldn't find library"
        end
      end
    end
  end
  
end
