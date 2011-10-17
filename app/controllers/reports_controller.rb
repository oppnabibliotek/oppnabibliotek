# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
class ReportsController < ApplicationController
  
  #append_before_filter :check_ownership_and_deny, :only => [:edit, :update, :destroy]
  append_before_filter :check_optional_authentication, :only => [:index]
  
  skip_before_filter :check_authentication, :check_authorization, :only => [ :index, :show ]
  
  ssl_required :new, :create, :edit, :update, :destroy, :reportabuse, :notifyabuser
  ssl_allowed :index, :show, :count
  
  @@open_library_abuse_report_email = "missbruk@oppnabibliotek.se"
  
  #def check_ownership_and_deny
  #  deny_authorization if !check_ownership(params[:id])
  #end
  
  #def check_ownership(report_id)
  #  return false if !@current_user || !report_id
  #  report = Report.find(report_id)
  #  if (@current_user.admin?)
  #    return true
  #  elsif (@current_user.local_admin?)
  #    return report.user.library.id == @current_user.library.id
  #  #elsif (@current_user.writer? || @current_user.member?) 
  #  #  return @current_user.id == tagging.user.id 
  #  else
  #    #This should never happen
  #    return false
  #  end
  #end
  
  # GET /reports
  # GET /reports.xml
  def index
    
    # TODO: please implement library_id filter for incoming and outgoing reports here
    
    set_sort_params(params)
    @reports = Report.where(params[:report]).order(params[:order]).limit(params[:limit]).offset(params[:offset]).all
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reports }
    end
  end
  
  def count

    params[:report] = {} if !params[:report]
    
    # TODO: please implement library_id filter for incoming and outgoing reports here
    
	# local admins should be able to get stats for their library only without necesarily knowing their library_id
	#if (params[:report][:library_id] == 'own' && @current_user.library.id)
	#  params[:report][:library_id] = @current_user.library.id
	#end

    sql_where_total = get_sql_where_statements(params[:report], "r")

    if sql_where_total != ""
      sql_where_total = "WHERE" + sql_where_total
      # Remove last 'AND'
      sql_where_total = strip_trailing_and(sql_where_total)
    end

    @total = Description.count_by_sql("SELECT count(*) FROM reports r %s" % [sql_where_total])

    respond_to do |format|
      format.html
      format.xml #{render :xml => @count}
    end
  end
  
  # GET /reports/1
  # GET /reports/1.xml
  def show
    @report = Report.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @report }
    end
  end
  
  # GET /reports/new
  # GET /reports/new.xml
  def new
    @report = Report.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @report }
    end
  end
  
  # GET /reports/1/edit
  def edit
    @report = Report.find(params[:id])
  end
  
  # POST /reports
  # POST /reports.xml
  def create
    
    respond_to do |format|
      if @report.save
        flash[:notice] = 'Report was successfully created.'
        format.html { redirect_to(@report) }
        format.xml  { render :xml => @report, :status => :created, :location => @report }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @report.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /reports/1
  # PUT /reports/1.xml
  def update
    @report = Report.find(params[:id])
    
    respond_to do |format|
      if @report.update_attributes(params[:report])
        flash[:notice] = 'Report was successfully updated.'
        format.html { redirect_to(@report) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @report.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /reports/1
  # DELETE /reports/1.xml
  def destroy
    @report = Report.find(params[:id])
    @report.destroy
    
    respond_to do |format|
      format.html { redirect_to(reports_url) }
      format.xml  { head :ok }
    end
  end
  
  def reportabuse
    
    begin
      
      Report.transaction do
        
        params[:report] = {} if !params[:report]
        
        ################################ Validate input ##############################
        if too_few_arguments(params) || too_many_arguments(params)
          error = "Exactly one of tag_id, description_id or assessment_id must be supplied."
        elsif params[:report][:tag_id]
          tag = Tag.find(params[:report][:tag_id])
          error = "The tag id is invalid" if !tag
        elsif params[:report][:description_id]
          description = Description.find(params[:report][:description_id])
          error = "The description id is invalid" if !description
        else
          assessment = Assessment.find(params[:report][:assessment_id])
          error = "The assessment id is invalid" if !assessment
        end
        ##############################################################################
        
        ############################# Prepare email ##################################
        if !error
          subject = params[:report][:subject]
          message = params[:report][:message]
          user = @current_user
          if user
            abuse_email_recipient_1 = user.library.abuse_email
            from1 = user.email
            from2 = abuse_email_recipient_1
            if tag
              abuser = get_user_by_tag_id(tag.id)
              abuse_email_recipient_2 = abuser.library.abuse_email
            elsif assessment
              abuse_email_recipient_2 = assessment.user.library.abuse_email
            else
              abuse_email_recipient_2 = description.user.library.abuse_email
            end
            
            recipients1 = [abuse_email_recipient_1, @@open_library_abuse_report_email]
            recipients2 = [abuse_email_recipient_2, @@open_library_abuse_report_email]
            
            params[:report][:user_id] = user.id
            @report = Report.new(params[:report])
          else
            error = "User could not be found"
          end
        end
        ############################################################################
        
        respond_to do |format|
          if error
            format.html #{ render :action => "new" }
            format.xml  { render :xml => create_error_message_xml(error), :status => :unprocessable_entity}
          elsif @report.save
            ReportAbuseMailer.report_abuse(subject, message, recipients1, user.email).deliver
            ReportAbuseMailer.report_abuse(subject, message, recipients2, abuse_email_recipient_1).deliver
            flash[:notice] = 'Your abuse report has been sent.'
            format.html { redirect_to(@report) }
            format.xml  { render :xml => @report, :status => :created, :location => @report }
          else
            format.html { render :action => "new" }
            format.xml  { render :xml => @report.errors, :status => :unprocessable_entity }
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
  
  def notifyabuser
    
    begin
      params[:report] = {} if !params[:report]
      
      ################################ Validate input ##############################
        if too_few_arguments(params) || too_many_arguments(params)
          error = "Exactly one of tag_id, description_id or assessment_id must be supplied."
        elsif params[:report][:tag_id]
          tag = Tag.find(params[:report][:tag_id])
          error = "The tag id is invalid" if !tag
        elsif params[:report][:description_id]
          description = Description.find(params[:report][:description_id])
          error = "The description id is invalid" if !description
        else
          assessment = Assessment.find(params[:report][:assessment_id])
          error = "The assessment id is invalid" if !assessment
        end
      ##############################################################################

      ############################# Prepare email ################################## 
      if !error
        subject = params[:report][:subject]
        message = params[:report][:message]
        
        if tag
          user = get_user_by_tag_id(tag.id)
        else
          user = assessment.user
        end
        
        if user
          from_address = user.library.abuse_email
          recipients = [user.email]
        else
          error = "User could not be found"
        end
      end 
      ##############################################################################
      
      respond_to do |format|
        if error
          flash[:notice] = 'Your notification to the user could not be sent.'
          format.html { redirect_to(@report) }
          format.xml  { render :xml => create_error_message_xml(error), :status => :unprocessable_entity }
        else
          ReportAbuseMailer.notify_abuser(subject, message, recipients, from_address).deliver
          flash[:notice] = 'Your notification to the user has been sent.'
          format.html { redirect_to(@report) }
          format.xml  { head :ok }
        end
      end
    rescue Exception => details
      respond_to do |format|
        format.html #{ render :action => "new" } 
        format.xml  { render :xml => details, :status => :unprocessable_entity}
      end
    end
  end
  
  private
  
  def get_user_by_tag_id(tag_id)
    tagging = Tagging.where("tag_id = ?", tag_id).order("created_at ASC").first
    return tagging.user if tagging
  end
  
  def too_many_arguments(params)
    if params[:report][:tag_id] && params[:report][:assessment_id]
      return true
    elsif params[:report][:tag_id] && params[:report][:description_id]
      return true
    elsif params[:report][:description_id] && params[:report][:assessment_id]
      return
    else
      return false
    end
    
  end
  
  def too_few_arguments(params)
    if !params[:report][:tag_id] && !params[:report][:assessment_id] && !params[:report][:description_id]
      return true
    end
  end
  
end
