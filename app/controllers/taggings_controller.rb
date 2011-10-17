# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
class TaggingsController < ApplicationController
  
  append_before_filter :check_ownership_and_deny, :only => [:edit, :update, :destroy]
  append_before_filter :check_optional_authentication, :only => [:index, :show]
  
  skip_before_filter :check_authentication, :check_authorization, :only => [ :index, :show ]
  
  ssl_required :new, :create, :edit, :update, :destroy
  ssl_allowed :index, :show, :count
  
  def check_ownership_and_deny
    deny_authorization if !check_ownership(params[:id])
  end
  
  def check_ownership(tagging_id)
    return false if !@current_user || !tagging_id
    tagging = Tagging.find(tagging_id)
    if (@current_user.admin?)
      return true
    elsif (@current_user.local_admin?)
      return tagging.user.library.id == @current_user.library.id
    elsif (@current_user.writer? || @current_user.member?) 
      return @current_user.id == tagging.user.id 
    else
      #This should never happen
      return false
    end
  end
  
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
  
  # GET /taggings
  # GET /taggings.xml
  def index
    set_sort_params(params, params[:tagging])
    
    params[:tagging] = {} if !params[:tagging]
    
    params[:tagging][:user_id] = params[:user_id] if params[:user_id]
    
    # Check if user information is supplied
    if params[:user_id]
      params[:tagging][:user_id] = params[:user_id]
      user_supplied = true
    elsif params[:tagging][:library_id] && params[:tagging][:username]
      user = User.where("library_id = ? and username = ?", params[:tagging][:library_id], params[:tagging][:username]).first
      if user
        params[:tagging][:user_id] = user.id
        user_supplied = true
      else
        error = "User could not be found"
      end
    elsif params[:tagging][:library_id]
      library_id = params[:tagging][:library_id]
    end
    
    # Remove parameters since they do not belong to tagging
    params[:tagging].delete("library_id")
    params[:tagging].delete("username")
    
    # Only show published taggings unless the user owns the tagging
    if user_supplied
      params[:tagging][:published] = true unless has_ownership_rights(params[:user_id])
    end
    
    if library_id
      @taggings = Tagging.where(get_condition_string(params[:tagging], library_id, "taggings")).joins(:users).order(params[:order]).limit(params[:limit]).offset(params[:offset]).all
    else
      @taggings = Tagging.where(params[:tagging]).order(params[:order]).limit(params[:limit]).offset(params[:offset]).all
    end

    # Filter out unpublished tagging which the current user does not have the rights to see
    if !user_supplied
      @taggings = @taggings.find_all { |tagging| 
        tagging.published || check_ownership(tagging.id)
      }
    end
    
    # Filter out blacklisted tags
    @taggings = @taggings.find_all { |tagging| 
      !check_blacklisting(tagging.tag.id)
    }
    
    @hitcount = @taggings.size
    
    respond_to do |format|
      if error
        format.xml  { render :xml => create_error_message_xml(error), :status => :unprocessable_entity}
      else
        format.html # index.html.erb
        format.xml
        format.atom
      end
    end
    
  end
  
  # GET /taggings/1
  # GET /taggings/1.xml
  def show
    @tagging = Tagging.find(params[:id])
    
    if @tagging 
      if check_blacklisting(@tagging.tag.id)
        deny_authorization
        return
      elsif !@tagging.published && !check_ownership(@tagging.id)
        deny_authorization
        return
      end  
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tagging }
    end
  end
  
  # GET /taggings/new
  # GET /taggings/new.xml
  def new
    @tagging = Tagging.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tagging }
    end
  end
  
  # GET /taggings/1/edit
  def edit
    @tagging = Tagging.find(params[:id])
  end
  
  # POST /taggings
  # POST /taggings.xml
  
  def create
    
    begin 
      Tagging.transaction do
        
        params[:tagging] = {} if !params[:tagging]
        params[:tagging][:isbn] = format_isbn(params[:tagging][:isbn]) if params[:tagging][:isbn]
        
        ############### Create tag if it does not exist #########
        if params[:tagging][:tag_id] 
          tag = Tag.find(params[:tagging][:tag_id])  
          error = "The tag id is invalid" if !tag
        elsif params[:tagging][:tag_name]
          tag = Tag.where("name = ?", params[:tagging][:tag_name]).first
          tag = createtag(params[:tagging][:tag_name]) if !tag
        else
          error = "Either tag_id or tag_name must be supplied."
        end
        ##########################################################
        
	# Book id OR edition id (or edition isbn) must be supplied.
	# If edition id (or edition isbn) is supplied, book id is ignored and derived from edition instead.     
        if !(params[:tagging][:book_id] || params[:tagging][:edition_id] || params[:tagging][:isbn])
          error = "Book id, edition id or edition isbn must be supplied."
	end

	# Book is supplied	
	if !error && (params[:tagging][:book_id]) 
          book = Book.find(params[:tagging][:book_id])
          error = "The book id is invalid." if !book
        end 

        # Edition if supplied
        if !error && (params[:tagging][:edition_id] || params[:tagging][:isbn])                   
          if params[:tagging][:edition_id]
            edition = Edition.where("id = ?", params[:tagging][:edition_id]).first
            error = "The edition id is invalid." if !edition
          else 
            edition = Edition.where("isbn = ?", params[:tagging][:isbn]).first
            error = "The isbn is invalid." if !edition
          end
        end
        
        #################### Create tagging ####################
        if !error
 	  # Edition trumphs book
          book_id = book.id if book
	  book_id = edition.book_id if edition
          params[:tagging][:book_id] = book_id 
          params[:tagging][:edition_id] = edition.id if edition
          params[:tagging][:tag_id] = tag.id 
          params[:tagging][:user_id] = @current_user.id
          params[:tagging][:published] = false if !params[:tagging][:published]
          tagging_params = {:book_id => params[:tagging][:book_id], :edition_id => params[:tagging][:edition_id], :tag_id => params[:tagging][:tag_id],
            :published => params[:tagging][:published], :user_id => params[:tagging][:user_id]}
          
          @tagging = Tagging.new(tagging_params)
        end   
        #############################################################
        
        
        respond_to do |format|
          if error
            format.html { render :action => "new" }
            format.xml  { render :xml => create_error_message_xml(error), :status => :unprocessable_entity}
          elsif @tagging.save
            flash[:notice] = 'Tagging was successfully created.'
            format.html { redirect_to(@tagging) }
            format.xml  { render :xml => @tagging, :status => :created, :location => @tagging }
          else
            format.html { render :action => "new" }
            format.xml  { render :xml => @tagging.errors, :status => :unprocessable_entity}
          end
        end
      end
    rescue Exception => details
      respond_to do |format|
        format.html { render :action => "new" } 
        format.xml  { render :xml => details, :status => :unprocessable_entity}
      end
    end 
    
  end
  
  # PUT /taggings/1
  # PUT /taggings/1.xml
  def update
    
    params[:tagging] = {} if !params[:tagging]
    params[:tagging][:isbn] = format_isbn(params[:tagging][:isbn]) if params[:tagging][:isbn]
    
    @tagging = Tagging.find(params[:id])
    
    respond_to do |format|
      if @tagging.update_attributes(params[:tagging])
        flash[:notice] = 'Tagging was successfully updated.'
        format.html { redirect_to(@tagging) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tagging.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /taggings/1
  # DELETE /taggings/1.xml
  def destroy
    @tagging = Tagging.find(params[:id])
    @tagging.destroy
    
    respond_to do |format|
      format.html { redirect_to(taggings_url) }
      format.xml  { head :ok }
    end
  end
  
  def count
    
    params[:tagging] = {} if !params[:tagging]
    
	# local admins should be able to get stats for their library only without necesarily knowing their library_id
	if (params[:tagging][:library_id] == 'own' && @current_user.library.id)
	  params[:tagging][:library_id] = @current_user.library.id
	end

    sql_where_total = get_sql_where_statements(params[:tagging], "t")
    #sql_where_blacklisted = "WHERE" + sql_where_total + " taggings.tag_id is not null GROUP BY b.tag_id"
    
    if sql_where_total != ""
      sql_where_total = "WHERE" + sql_where_total
      # Remove last 'AND'
      sql_where_total = strip_trailing_and(sql_where_total)
    end
    
    @total = Tagging.count_by_sql("SELECT count(*) FROM taggings t inner join users u on t.user_id = u.id inner join libraries l on u.library_id = l.id inner join counties c on l.county_id = c.id %s" % [sql_where_total])
    
    #@blacklisted = Tagging.count_by_sql("SELECT count(*) FROM taggings t inner join users u on t.user_id = u.id inner join libraries l on u.library_id = l.id inner join counties c on l.county_id = c.id inner join tags on t.tag_id = tags.id inner join blacklistings b on tags.id = b.tag_id %s") % [sql_where_blacklisted])
    # not fisnished
    
    respond_to do |format|
      format.html
      format.xml #{render :xml => @count}
    end
  end
  
  private
  
  def createtag(name)
    tag_params = { :name => name }
    @tag = Tag.new(tag_params)
    @tag.save
    return @tag
  end
  
end
