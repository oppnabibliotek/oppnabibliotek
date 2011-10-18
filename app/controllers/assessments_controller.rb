# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
class AssessmentsController < ApplicationController
  
  append_before_filter :check_ownership_and_deny, :only => [:edit, :update, :destroy]
  append_before_filter :check_optional_authentication, :only => [:index, :show]
  
  skip_before_filter :check_authentication, :check_authorization, :only => [ :index, :show ]
  
  ssl_required :new, :create, :edit, :update, :destroy
  ssl_allowed :index, :show, :count
  
  def check_ownership_and_deny
    deny_authorization if !check_ownership(params[:id])
  end
  
  def check_ownership(assessment_id)
    return false if !@current_user || !assessment_id
    assessment = Assessment.find(assessment_id)
    if (@current_user.admin?)
      return true
    elsif (@current_user.local_admin?)
      return assessment.user.library.id == @current_user.library.id
    elsif (@current_user.writer? || @current_user.member?) 
      return @current_user.id == assessment.user.id 
    else
      #This should never happen
      return false
    end
  end
  
  def check_blacklisting(assessment_id)
    assessment = Assessment.find(assessment_id)
    if @current_user
      blacklistings = assessment.blacklistings.find_all {|blacklisting| blacklisting.global || blacklisting.library_id = @current_user.library.id }
    else
      blacklistings = assessment.blacklistings
    end
    # Returns true if assessment is blacklisted 
    return blacklistings.size > 0
  end
  
  # GET /assessments
  # GET /assessments.xml
  # GET /users/1/assessments
  # GET /users/1/assessments.xml
  # GET /books/1/assessments
  # GET /books/1/assessments.xml
  # GET /editions/1/assessments
  # GET /editions/1/assessments.xml 
  def index
    set_sort_params(params, params[:assessment])
    
    params[:assessment] = {} if !params[:assessment]
    
    user_supplied = false
    
    # Check if user information is supplied
    if params[:user_id]
      params[:assessment][:user_id] = params[:user_id] 
      user_supplied = true
    elsif params[:assessment][:library_id] && params[:assessment][:username]
      user = User.where("library_id = ? and username = ?", params[:assessment][:library_id], params[:assessment][:username]).first
      if user
        params[:assessment][:user_id] = user.id
        user_supplied = true
      else
        error = "User could not be found"
      end
    elsif params[:assessment][:library_id]
      library_id = params[:assessment][:library_id]
    end
    
	# Users should be able to get stats for their library without necessarily knowing their library_id
	if (library_id == 'own' && @current_user.library.id)
	  library_id = @current_user.library.id
	end
    
    # Remove parameters since they do not belong to assessment
    params[:assessment].delete("library_id")
    params[:assessment].delete("username")
    
    params[:assessment][:edition_id] = params[:edition_id] if params[:edition_id]
    params[:assessment][:book_id] = params[:book_id] if params[:book_id]
    
    # Only show published assessments unless the user owns the assessments
    if user_supplied
      params[:assessment][:published] = true unless has_ownership_rights(params[:user_id])
    end
    
    if library_id
      @assessments = Assessment.where(get_condition_string(params[:assessment], library_id, "assessments")).joins("INNER JOIN users u ON u.id = assessments.user_id").order(params[:order]).limit(params[:limit]).offset(params[:offset]).all
    else
      @assessments = Assessment.where(params[:assessment]).order(params[:order]).limit(params[:limit]).offset(params[:offset]).all
    end
    
    # Filter out unpublished assessments which the current user does not have the rights to see
    if !user_supplied
      @assessments = @assessments.find_all { |assessment| 
       (assessment.published || check_ownership(assessment.id)) && !check_blacklisting(assessment.id)
      }
    end
    
    # Filter out blacklisted assessments
    @assessments = @assessments.find_all { |assessment| 
      !check_blacklisting(assessment.id)
    }
    
    @hitcount = @assessments.size
    @average = Assessment.average(:grade, :conditions => params[:assessment])
    
    respond_to do |format|
      if error
        format.xml  { render :xml => create_error_message_xml(error), :status => :unprocessable_entity}
      else
        format.html
        format.xml
        format.atom
      end
    end
    
  end
  
  def count
    
    params[:assessment] = {} if !params[:assessment]
    
	# Users should be able to get stats for their library without necessarily knowing their library_id
	if (params[:assessment][:library_id] == 'own' && @current_user.library.id)
	  params[:assessment][:library_id] = @current_user.library.id
	end

    sql_where_total = get_sql_where_statements(params[:assessment], "a")

    sql_where_published = "WHERE" + sql_where_total + " a.published = true"
    sql_where_blacklisted = "WHERE" + sql_where_total + " a.id is not null GROUP BY assessment_id"
    
    if sql_where_total != ""
      sql_where_total = "WHERE" + sql_where_total
      # Remove last 'AND'
      sql_where_total = strip_trailing_and(sql_where_total)
    end
    
    @total = Assessment.count_by_sql("SELECT count(*) FROM assessments a inner join users u on a.user_id = u.id inner join libraries l on u.library_id = l.id inner join counties c on l.county_id = c.id %s" % [sql_where_total])
    
    @published = Assessment.count_by_sql("SELECT count(*) FROM assessments a inner join users u on a.user_id = u.id inner join libraries l on u.library_id = l.id inner join counties c on l.county_id = c.id %s" % [sql_where_published])
    
    @blacklisted = Assessment.count_by_sql("SELECT count(*) FROM assessments a inner join users u on a.user_id = u.id inner join libraries l on u.library_id = l.id inner join counties c on l.county_id = c.id inner join blacklistings b on a.id = b.assessment_id %s" % [sql_where_blacklisted])
    
    respond_to do |format|
      format.html
      format.xml #{render :xml => @count}
    end
  end
  
  # GET /assessments/1
  # GET /assessments/1.xml
  def show
    @assessment = Assessment.find(params[:id])
    
    if @assessment 
      if check_blacklisting(@assessment.id)
        deny_authorization
        return
      elsif !@assessment.published && !check_ownership(@assessment.id)
        deny_authorization
        return
      end  
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @assessment }
    end
  end
  
  # GET /assessments/new
  # GET /assessments/new.xml
  def new
    @assessment = Assessment.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @assessment }
    end
  end
  
  # GET /assessments/1/edit
  def edit
    @assessment = Assessment.find(params[:id])
  end
  
  # POST /assessments
  # POST /assessments.xml
  def create
    begin 
      Assessment.transaction do        
        params[:assessment] = {} if !params[:assessment]
        params[:assessment][:isbn] = format_isbn(params[:assessment][:isbn]) if params[:assessment][:isbn]

	# Book id OR edition id (or edition isbn) must be supplied.
	# If edition id (or edition isbn) is supplied, book id is ignored and derived from edition instead.     
        if !(params[:assessment][:book_id] || params[:assessment][:edition_id] || params[:assessment][:isbn])
          error = "Book id, edition id or edition isbn must be supplied."
	end

	# Book is supplied	
	if !error && (params[:assessment][:book_id]) 
          book = Book.find(params[:assessment][:book_id])
          error = "The book id is invalid." if !book
        end 

        # Edition if supplied
        if !error && (params[:assessment][:edition_id] || params[:assessment][:isbn])                   
          if params[:assessment][:edition_id]
            edition = Edition.where("id = ?", params[:assessment][:edition_id]).first
            error = "The edition id is invalid." if !edition
          else 
            edition = Edition.where("isbn = ?", params[:assessment][:isbn]).first
            error = "The isbn is invalid." if !edition
          end
        end

        # Create assessment
        if !error 
	  # Edition trumphs book
          book_id = book.id if book
	  book_id = edition.book_id if edition
          params[:assessment][:book_id] = book_id 
          params[:assessment][:edition_id] = edition.id if edition
          params[:assessment][:user_id] = @current_user.id
          params[:assessment][:published] = false if !params[:assessment][:published]
          
          assessment_params = {:book_id => params[:assessment][:book_id], :edition_id => params[:assessment][:edition_id], :grade => params[:assessment][:grade],
            :published => params[:assessment][:published], :comment_header => params[:assessment][:comment_header], 
            :comment_text => params[:assessment][:comment_text], :user_id => params[:assessment][:user_id]}
          
          @assessment = Assessment.new(assessment_params)
        end
        
        respond_to do |format|
          if error
            format.html #{ render :action => "new" }
            format.xml  { render :xml => create_error_message_xml(error), :status => :unprocessable_entity}
          elsif @assessment.save
            flash[:notice] = 'Assessment was successfully created.'
            format.html { redirect_to(@assessment) }
            format.xml  { render :xml => @assessment, :status => :created, :location => @assessment }
          else
            format.html #{ render :action => "new" }
            format.xml  { render :xml => @assessment.errors, :status => :unprocessable_entity}
          end
        end
      end
    rescue Exception => details
      respond_to do |format|
        format.html #{ render :action => "new" } 
        format.xml  { render :xml => details, :status => :unprocessable_entity}
      end
    end 
    
  end
  
  
  # PUT /assessments/1
  # PUT /assessments/1.xml
  def update
    
    params[:assessment] = {} if !params[:assessment]
    @assessment = Assessment.find(params[:id])
    respond_to do |format| # Update is restricted to the following 4 fields
      if @assessment.update_attributes({:grade => params[:assessment][:grade], :comment_header => params[:assessment][:comment_header], 
          :comment_text => params[:assessment][:comment_text], :published => params[:assessment][:published]})
        flash[:notice] = 'Assessment was successfully updated.'
        format.html { redirect_to(@assessment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @assessment.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /assessments/1
  # DELETE /assessments/1.xml
  def destroy
    @assessment = Assessment.find(params[:id])
    @assessment.destroy
    
    respond_to do |format|
      format.html { redirect_to(assessments_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
end
