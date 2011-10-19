# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
class BlacklistingsController < ApplicationController
  
  append_before_filter :check_ownership_and_deny, :only => [:edit, :update, :destroy]
  append_before_filter :check_optional_authentication, :only => [:index]
  
  ssl_required :new, :create, :edit, :update, :destroy
  ssl_allowed :index, :show
  
  def check_ownership_and_deny
    deny_authorization if !check_ownership(params[:id])
  end
  
  # GET /blacklistings
  # GET /blacklistings.xml
  def index
    
    set_sort_params(params)
    
    @blacklistings = Blacklisting.where(params[:blacklisting]).order(params[:order]).limit(params[:limit]).offset(params[:offset])
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @blacklistings }
    end
  end
  
  # GET /blacklistings/1
  # GET /blacklistings/1.xml
  def show
    @blacklisting = Blacklisting.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @blacklisting }
    end
  end
  
  # GET /blacklistings/new
  # GET /blacklistings/new.xml
  def new
    @blacklisting = Blacklisting.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @blacklisting }
    end
  end
  
  # GET /blacklistings/1/edit
  def edit
    @blacklisting = Blacklisting.find(params[:id])
  end
  
  # POST /blacklistings
  # POST /blacklistings.xml
  def create
    params[:blacklisting] = {} if !params[:blacklisting]
    
    ################################ Validate input ###############################
    if !params[:blacklisting][:library_id] && (!params[:blacklisting][:global] || (params[:blacklisting][:global] && params[:blacklisting][:global] == false))
      error = "Library_id must be supplied unless blacklisting is global."
    elsif too_few_arguments(params) || too_many_arguments(params)
      error = "Exactly one of tag_id, description_id or assessment_id must be supplied."
    elsif params[:blacklisting][:tag_id]
      tag = Tag.find(params[:blacklisting][:tag_id])
      error = "The tag id is invalid" if !tag
    elsif params[:blacklisting][:assessment_id]
      assessment = Assessment.find(params[:blacklisting][:assessment_id])
      error = "The assessment id is invalid" if !assessment
    else
      description = Description.find(params[:blacklisting][:description_id])
      error = "The description id is invalid" if !description
    end
    ##############################################################################
    
	# Users should be able to get stats for their library without necessarily knowing their library_id
	if (params[:blacklisting][:library_id] == 'own' && @current_user.library.id)
	  params[:blacklisting][:library_id] = @current_user.library.id
	end
    
    @blacklisting = Blacklisting.new(params[:blacklisting]) if !error
    
    respond_to do |format|
      if error 
            format.html #{ render :action => "new" }
            format.xml  { render :xml => create_error_message_xml(error), :status => :unprocessable_entity}
      elsif @blacklisting.save
        flash[:notice] = 'Blacklisting was successfully created.'
        format.html { redirect_to(@blacklisting) }
        format.xml  { render :xml => @blacklisting, :status => :created, :location => @blacklisting }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @blacklisting.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /blacklistings/1
  # PUT /blacklistings/1.xml
  def update
    @blacklisting = Blacklisting.find(params[:id])
    
    respond_to do |format|
      if @blacklisting.update_attributes(params[:blacklisting])
        flash[:notice] = 'Blacklisting was successfully updated.'
        format.html { redirect_to(@blacklisting) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @blacklisting.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /blacklistings/1
  # DELETE /blacklistings/1.xml
  def destroy
    @blacklisting = Blacklisting.find(params[:id])
    @blacklisting.destroy
    
    respond_to do |format|
      format.html { redirect_to(blacklistings_url) }
      format.xml  { head :ok }
    end
  end
  
  private 
  
  def too_many_arguments(params)
    if params[:blacklisting][:tag_id] && params[:blacklisting][:assessment_id]
      return true
    elsif params[:blacklisting][:tag_id] && params[:blacklisting][:description_id]
      return true
    elsif params[:blacklisting][:description_id] && params[:blacklisting][:assessment_id]
      return
    else
      return false
    end
    
  end
  
  def too_few_arguments(params)
    if !params[:blacklisting][:tag_id] && !params[:blacklisting][:assessment_id] && !params[:blacklisting][:description_id]
      return true
    end
  end
  
end
