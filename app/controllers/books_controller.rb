# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
require 'set'

class BooksController < ApplicationController
  
  skip_before_filter :check_authentication, :check_authorization, :only => [ :index, :show, :search, :authors ]
  
  ssl_required :new, :create, :edit, :update, :destroy
  ssl_allowed :index, :show, :search, :authors
  
  @@bookfields = ["title", "authorfirstname", "authorlastname", "booktitle_part1", "booktitle_part1", "group_inst", "agegroupname", "targetgroupname", "signumname", "reserved", "keyword"]
  @@editionfields = ["isbn", "year", "illustrator", "translator", "recordnr", "recordcompany", "auxcreator", "image", "published", "manual", "mediatype", "mediatypecode","ssb_key"]
  @@descriptionfields = ["text"]
  @@userfields = ["libraryname", "userfirstname", "userlastname", "username"]
  
  @@sortfields = {"title" => "title_for_sort", "author" => "author_for_sort", "year" => "year_for_sort", "date" => "date_for_sort"}
  
  @@freequeryextraparams = ["reserved", "published", "libraryname"]
  
  
  # GET /books
  # GET /books.xml
  def index
    
    set_sort_params(params, params[:book])
    if params[:order] && params[:order].index("activity") == 0
      if params[:order].index("activity_assessments") == 0
        sql_where_total = get_sql_where_statements(params[:user], "a", true)
        query = "select b.*, count(*) as user_assessments from books b " +
          "inner join assessments a on a.book_id = b.id inner join users u on u.id = a.user_id inner join libraries l on u.library_id = l.id " +
          "inner join counties c on l.county_id = c.id " + sql_where_total + " group by b.id order by count(*)"
      elsif params[:order].index("activity_grades") == 0
        sql_where_total = get_sql_where_statements(params[:user], "a", true)
        query = "select b.*, avg(a.grade) as user_assessments from books b " +
          "inner join assessments a on a.book_id = b.id inner join users u on u.id = a.user_id inner join libraries l on u.library_id = l.id " +
          "inner join counties c on l.county_id = c.id " + sql_where_total + " group by b.id order by avg(a.grade)"
      elsif params[:order].index("activity_taggings") == 0
        sql_where_total = get_sql_where_statements(params[:user], "t", true)
        query = "select b.*, count(*) as user_assessments from books b " +
          "inner join taggings t on a.book_id = b.id inner join users u on u.id = t.user_id inner join libraries l on u.library_id = l.id " +
          "inner join counties c on l.county_id = c.id " + sql_where_total + " group by b.id order by count(*)"
      end
      query += " desc" if !params[:reverse]
      @books = Book.find_by_sql(query)
    else
      @books = Book.find(:all, :conditions => params[:book], :limit => params[:limit], :order => params[:order], :offset => params[:offset])
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @books.to_xml }
      format.atom
    end
  end
  
  # GET /books/1
  # GET /books/1.xml
  def show
    @book = Book.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @book.to_xml(:include => { :keywords => {}, :sb_keywords => {}, :targetgroup => {}, :agegroup => {}, :signum => {}, :editions => { :include => { :descriptions => { :include => { :user  => { :except => [:email, :password_hash]}}}}}, :assessments => {}, :taggings => { :include => :tag } }) } 
    end
  end
  
  # GET /books/new
  # GET /books/new.xml
  def new
    @book = Book.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @book }
    end
  end
  
  # GET /books/1/edit
  def edit
    @book = Book.find(params[:id])
  end
  
  # POST /books
  # POST /books.xml
  def create
    @book = Book.new(params[:book])
    
    respond_to do |format|
      if @book.save_and_index
        flash[:notice] = 'Book was successfully created.'
        format.html { redirect_to(@book) }
        format.xml  { render :xml => @book, :status => :created, :location => @book }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @book.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /books/1
  # PUT /books/1.xml
  def update
    @book = Book.find(params[:id])
    
    respond_to do |format|
      if @book.update_attributes_and_index(params[:book])
        flash[:notice] = 'Book was successfully updated.'
        format.html { redirect_to(@book) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @book.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /books/1
  # DELETE /books/1.xml
  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    
    respond_to do |format|
      format.html { redirect_to(books_url) }
      format.xml  { head :ok }
    end
  end
  
  #Search for books, and filter the results
  def search
    books, editionparams, descriptionparams = searchbooks(params)
    @hitcount = books.size
    filterbooks(books, editionparams, descriptionparams)
    @books = books
    respond_to do |format|
      format.html # search.html.erb
      format.xml
      format.atom
      #format.xml  { render :xml => @books }
    end
  end
  
  # GET /books/authors
  def authors
    params[:order] = "authorlastname" if !params[:order]
    books = Book.find(:all, :order=> params[:order])
    authorset = Set.new()
    books.each{|book|
      book.authorfirstname ||= ""
      book.authorlastname ||= ""
      authorset.add([book.authorfirstname, book.authorlastname]) if ((book.authorfirstname && book.authorfirstname.length > 0) || (book.authorlastname && book.authorlastname.length > 0))
    }
    @authors = authorset.to_a
    @authors.sort! { |a,b| a[1] <=> b[1] }
    respond_to do |format|
      format.html
      format.xml
    end
  end
  
  private
  
  def searchbooks(params)
    
    params[:isbn] = format_isbn(params[:isbn]) if params[:isbn]
    
    params[:isbn] = params[:isbn] + '*' if params[:isbn]
    
    filterterms = ["action", "controller", "limit"]
    
    bookparams = {}
    editionparams = {}
    descriptionparams = {}
    freequeryextraparams = {}
    
    if params[:limit]
      limit = Integer(params[:limit])
    else
      limit = 10
    end
    
    if params[:offset]
      offset = Integer(params[:offset])
    else
      offset = 0
    end
    
    if params[:order] && @@sortfields.keys.include?(params[:order])
      sortreverse = false
      if params[:reverse]
        sortreverse = true
      end
      sortfieldparam = @@sortfields[params[:order]]
      ferret_sortfield = Ferret::Search::SortField.new(sortfieldparam, :reverse => sortreverse)
    end
    
    params.each_key {|key|
      if (!filterterms.include?(key))
        if (@@editionfields.include?(key))
          editionparams[key] = params[key]
        elsif ((@@descriptionfields + @@userfields).include?(key))
          descriptionparams[key] = params[key]
        elsif (@@bookfields.include?(key))
          bookparams[key] = params[key]
        end
        if (@@freequeryextraparams.include?(key))
          logger.error("key: " + key)
          freequeryextraparams[key] = params[key]
        end
      end
    }
    
    query = ""
    if (params[:freequery2])
      freequeries = params[:freequery2].split(":")
      extraqueries = freequeryextraparams.keys.collect{|key| 
        "#{key}:#{freequeryextraparams[key]}"
      }
      query = (freequeries + extraqueries).join(" AND ")
      logger.error("query: " + query)
    elsif (params[:freequery1])
      queries = params[:freequery1].split(":")
      queryelement = "(" + queries.join(" AND ") + ")"
      queryelements = []
      totalfields = @@bookfields + @@editionfields + @@userfields
      totalfields.each {|field|
        queryelements << (field + ":" + queryelement)
      }
      query = queryelements.join(" OR ")
    else
      query = query + bookparams.keys.collect{|key| 
        "#{key}:#{bookparams[key]}"
      }.join(' AND ')
      if editionparams.length > 0
        if query.length > 0
          query = query + " AND " 
        end
        query = query + editionparams.keys.collect{
          |key| "#{key}:#{editionparams[key]}"
        }.join(' AND ')
      end
      if descriptionparams.length > 0
        if query.length > 0
          query = query + " AND " 
        end
        query = query + descriptionparams.keys.collect{
          |key| "#{key}:#{descriptionparams[key]}"
        }.join(' AND ') 
      end
    end
    
    if query.eql?("")
      query = "dummy:dummy AND published:true"
    end

    results = Book.find_with_ferret(query, :limit => limit, :offset => offset, :sort => ferret_sortfield)

    return results, editionparams, descriptionparams

  end
  
  def filterbooks(books, editionparams, descriptionparams)
    books.each{|book|
      has_edition_to_show = false
      book.editions.each{|edition|
        if editionparams.length > 0
          edition.show_after_search = filteredition?(edition, editionparams)
        else
          edition.show_after_search = true
        end
        if edition.show_after_search
          has_description_to_show = false
          edition.descriptions.each{|description|
            if descriptionparams.length > 0
              description.show_after_search = filterdescription?(description, descriptionparams)
            else
              description.show_after_search = true
            end
            has_description_to_show = true if description.show_after_search
          }
          edition.show_after_search = has_description_to_show
        end
        has_edition_to_show = true if edition.show_after_search
      }
      book.show_after_search = has_edition_to_show
    }
    
  end
  
  def filteredition?(edition, editionparams)
    editionparams.keys.each{|key|
      edition_value = edition.send(key).to_s
      # Filtering on published is necessary here, because if the query was a free query,
      # the published flag has not been taken into account by the previous search.
      if key.eql?("published") 
        if params[:published] 
          if !edition.published
            return false
          end
        end
      elsif key.eql?("isbn")
        sent_isbn = params[:isbn].gsub(/\*/, '')
        if !edition_value || !edition_value.index(sent_isbn) == 0
          return false
        end
      elsif key.eql?("illustrator")
        illustrator_names = edition_value.split(" ")
        illustrator_names.each{|illustrator_name|
          return true if illustrator_name.downcase.eql?(editionparams[key].downcase)
        }
      elsif !edition_value || !edition_value.downcase.eql?(editionparams[key].downcase)
        return false
      end
    }
    return true
  end
  
  def filterdescription?(description, descriptionparams)
    descriptionparams.keys.each{|key|
      description_value = nil
      if key.eql?("libraryname")
        description_value = description.user.library.name if description.user && description.user.library
      elsif key.eql?("userfirstname")
        description_value = description.user.firstname if description.user
      elsif key.eql?("userlastname")
        description_value = description.user.lastname if description.user
      elsif key.eql?("username")
        description_value = description.user.username if description.user
      else
        description_value = description.send(key).to_s
      end
      if !description_value || !description_value.downcase.eql?(descriptionparams[key].downcase)
        return false;
      end
    }
    return true
  end
  
end
