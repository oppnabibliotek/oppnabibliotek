# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SslRequirement
  
  self.allow_forgery_protection = false

  @@default_limit = 50
  @@default_offset = 0
  
  helper :all # include all helpers, all the time
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'a28ed88d60d1d0766fbd7be0b88bfde8'
  
  helper_method :logged_in?
  
  before_filter :check_developer_key, :check_authentication, :check_authorization
  
  
  def ssl_required?
    return false if request.local? || Rails.env.test?
    super
  end
  
  def check_developer_key
    return if request.local? || Rails.env.test?
    respond_to do |format|
      format.html do
        return
      end
      format.xml do
        if !params[:dev_key] 
          deny_dev_key
        else
          dev_key = Library.where("dev_key = ?", params[:dev_key])
          deny_dev_key unless dev_key
        end
      end
      format.atom do
        if !params[:dev_key] 
          deny_dev_key
        else
          dev_key = Library.where("dev_key = ?", params[:dev_key])
          deny_dev_key unless dev_key
        end
      end
    end
  end
  
  def deny_dev_key
    error_text = "Du har ej tillgång till efterfrågad resurs. Utvecklarnyckel saknas eller är ogiltig."
    render :text => error_text + "\n", :status => "401 Unauthorized"
  end  
  
  def check_authentication
    if logged_in?
      @current_user = User.find(session[:user_id])
    else
      respond_to do |format|
        format.html do
          flash[:notice] = "Please log in"
          redirect_to new_session_url
        end
        format.xml do    
          user = authenticate_with_http_basic do |login, password|
            User.authenticate(login, password)
          end
          if user
            @current_user = user
          else
            request_http_basic_authentication
          end
        end
      end
    end
  end
  
  def check_optional_authentication
    if logged_in?
      @current_user = User.find(session[:user_id])
    else
      respond_to do |format|
        format.html do
          #TODO: does not work right now
        end
        format.atom do
          #TODO: does not work right now
        end
        format.xml do   
          user = authenticate_with_http_basic do |login, password|
            User.authenticate(login, password)
          end
          if user
            @current_user = user
          end
        end
      end
    end
  end
  
  def check_authorization
    unless @current_user.roles.detect{|role|
        role.rights.detect{|right|
          right.action == action_name && right.controller == controller_name
        }
      }
      deny_authorization
    end
  end
  
  def logged_in?
    session[:user_id]
  end
  
  def deny_authorization
    error_text = "Du har ej tillgång till den efterfrågade resursen."
    respond_to do |format|
      format.html do
        flash[:notice] = error_text
        request.env["HTTP_REFERER"] ? (redirect_to :back) : (redirect_to new_session_url)
      end
      format.xml do   
        render :text => error_text + "\n", :status => "401 Unauthorized"
      end
    end    
  end
  
  #object_params are params specific to the object type at hand, for example params[:book] or params[:assessment]
  def set_sort_params(params, object_params=nil) 
    
    if object_params
      if object_params[:date_from]
        if object_params[:date_to]
          object_params[:created_at] = object_params[:date_from]..object_params[:date_to]
        else
          object_params[:created_at] = object_params[:date_from]..Date.today.to_s
        end
      elsif object_params[:date_to]
        object_params[:created_at] = "2000-01-01"..object_params[:date_to]
      end
      object_params.delete(:date_from)
      object_params.delete(:date_to)
    end

    params[:limit] ||= @@default_limit
    params[:offset] ||= @@default_offset
    
	# bug-fix that prevents the errors like Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near ''2'' at line 1: SELECT  `assessments`.* FROM `assessments` LIMIT 20 OFFSET '2'
	params[:offset] = params[:offset].to_i

    params.delete(:limit) if params[:limit].eql?("0") # 0 means "no limit"
    
    if params[:order] && !params[:order].eql?("byuse")
      params[:order] = params[:order] + " desc" if params[:reverse] 
    end
    
  end
  
  def has_ownership_rights(user_id)
    return false if !@current_user || !user_id
    owner = User.find(user_id)
    if (@current_user.admin?)
      return true
    elsif (@current_user.local_admin?)
      return owner.library.id == @current_user.library.id
    elsif (@current_user.writer? || @current_user.member?) 
      return owner.id == @current_user.id
    else
      #This should never happen
      return false
    end
  end
  
  def createbook(title, authorfirstname, authorlastname, signum_id)
    book_params = { :title => title, :authorfirstname => authorfirstname, :authorlastname => authorlastname, :signum_id => signum_id }
    
    book = Book.new(book_params) 
    book.save
    return book
  end
  
  def createedition(book_id, isbn, mediatypecode, libris_id)
    
    isbn = format_isbn(isbn) if isbn
    
    edition_params = { :book_id => book_id, :isbn => isbn, :mediatypecode => mediatypecode} # TODO: add libris-id , :libris_id => libris_id }
    
    edition = Edition.new(edition_params) 
    edition.save
    return edition
  end
  
  def create_error_message_xml(message)
    return '<?xml version="1.0" encoding="UTF-8"?><errors><error>' + message + '</error></errors>'
  end
  
  def format_isbn(isbn)
    regexp = /[^0-9]*/
    isbn = isbn.gsub(regexp, '') if isbn  
  end

  def get_sql_where_statements(params, activity_table, with_where=nil)
    sql_where_total = ""
    if params
      sql_where_total << " u.library_id = '%s' AND" % params[:library_id] if params[:library_id]
      sql_where_total << " c.id = '%s' AND" % params[:county_id] if params[:county_id]
      sql_where_total << " " + activity_table + ".created_at > '%s' AND" % params[:date_from] if params[:date_from]
      sql_where_total << " " + activity_table + ".created_at < '%s' AND" % params[:date_to] if params[:date_to]
    end
    if with_where
      if sql_where_total != ""
        sql_where_total = "WHERE " + sql_where_total
        sql_where_total = strip_trailing_and(sql_where_total)
      end
    end
    return sql_where_total
  end

  def strip_trailing_and(sql_string)
    # Remove last 'AND'
    return sql_string[0..sql_string.length()-4]
  end

  def get_condition_string(params, library_id, activity_table)
    sql_where_total = "u.library_id = '%s' AND" % library_id
    params.keys.each { |key|
      if key.eql?("created_at")
        from_date = params[key].first
        to_date = params[key].last
        sql_where_total << " " + activity_table + "." + key + " >= '%s' AND" % from_date
        sql_where_total << " " + activity_table + "." + key + " <= '%s' AND" % to_date
      else
        sql_where_total << " " + activity_table + "." + key + " = '%s' AND" % params[key]
      end
    }
    if sql_where_total != ""
        sql_where_total = strip_trailing_and(sql_where_total)
    end
    return sql_where_total
  end
end
