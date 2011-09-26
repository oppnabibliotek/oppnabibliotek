# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
# == Schema Information
# Schema version: 55
#
# Table name: books
#
#  id              :integer(4)      not null, primary key
#  title           :string(255)
#  authorfirstname :string(255)
#  authorlastname  :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  signum_id       :integer(4)
#  temp_bookid     :integer(4)
#  temp_signumtext :string(100)
#  targetgroup_id  :integer(4)
#  agegroup_id     :integer(4)
#  booktitle_part1 :string(255)
#  booktitle_part2 :string(255)
#  group_inst      :string(255)
#  reserved        :boolean(1)
#

require 'set'

class Book < ActiveRecord::Base
  
  @@bookfields = {:title => {}, :authorfirstname => {}, :authorlastname => {}, :booktitle_part1 => {}, :booktitle_part2 => {}, :group_inst => {}, :agegroupname => {}, :targetgroupname => {}, :signumname => {}, :reserved => {}, :keyword => {}}
  @@editionfields = {:isbn => {}, :year => {}, :illustrator => {}, :translator => {}, :recordnr => {}, :recordcompany => {}, :auxcreator => {}, :image => {}, :published => {}, :manual => {}, :mediatype => {}, :mediatypecode => {}}
  @@descriptionfields = {:text => {}}
  @@userfields = {:libraryname => {}, :userfirstname => {}, :userlastname => {}, :username => {}}
  @@dummyfield = {:dummy => {} }
  @@sortfields = {:title_for_sort => {:index => :untokenized}, :author_for_sort => {:index => :untokenized}, :year_for_sort => {:index => :untokenized}, :date_for_sort => {:index => :untokenized}}
  
  #acts_as_ferret( { :fields => @@bookfields.merge(@@editionfields).merge(@@descriptionfields).merge(@@userfields).merge(@@dummyfield).merge(@@sortfields) }, 
  #                { :analyzer => Ferret::Analysis::StandardAnalyzer.new([]), :remote => true })

  acts_as_ferret( { :fields => @@bookfields.merge(@@editionfields).merge(@@descriptionfields).merge(@@userfields).merge(@@dummyfield).merge(@@sortfields), 
                  :ferret => { :analyzer => Ferret::Analysis::StandardAnalyzer.new([]), :remote => true } })

  has_many :editions, :dependent => :delete_all
  has_many :assessments, :dependent => :delete_all
  belongs_to :signum 
  belongs_to :targetgroup
  belongs_to :agegroup
  has_and_belongs_to_many :keywords
  has_and_belongs_to_many :sb_keywords
  has_many :taggings, :dependent => :delete_all
  has_many :tags, :through => :taggings
  
  attr_accessor :show_after_search
  
  #lägg också in kontroll som kollar att om det finns en agegroups till targetgroupen så måste en sådan väljas.
  #validates_presence_of  :title, :authorfirstname, :authorlastname, :signum,
  #:message => "can't be empty"
  
  def agegroupname
    self.agegroup.name if self.agegroup  
  end
  
  def targetgroupname
    self.targetgroup.name if self.targetgroup  
  end
  
  def signumname
    self.signum.name if self.signum
  end
  
  def keyword
    keywordset = Set.new()
    keywordset.merge(self.keywords.collect{|keyword| keyword.name})
    keywordset.merge(self.sb_keywords.collect{|keyword| keyword.name})
    keywordset.to_a.join(' ')
  end
  
  def isbn
    self.editions.collect{|edition| edition.isbn}.join(' ')
  end
  
  def year
    self.editions.collect{|edition| edition.year}.join(' ')
  end
  
  def illustrator
    self.editions.collect{|edition| edition.illustrator}.join(' ')
  end
  
  def translator
    self.editions.collect{|edition| edition.translator}.join(' ')
  end
  
  def auxcreator
    self.editions.collect{|edition| edition.auxcreator}.join(' ')
  end
  
  def recordnr
    self.editions.collect{|edition| edition.recordnr}.join(' ')
  end
  
  def recordcompany
    self.editions.collect{|edition| edition.recordcompany}.join(' ')
  end
  
  def mediatype
    self.editions.collect{|edition| edition.mediatype}.join(' ')
  end
  
  def mediatypecode
    self.editions.collect{|edition| edition.mediatypecode}.join(' ')
  end
  
  def image
    unless self.editions.detect{ |edition|
        edition.imageurl
      }
      return false
    end
    return true
  end
  
  def published
    unless self.editions.detect{ |edition|
        edition.published
      }
      return false
    end
    return true
  end
  
  def manual
    unless self.editions.detect{ |edition|
        edition.manual
      }
      return "no"
    end
    return "yes"  
  end
  
  def username
    self.editions.collect{|edition| 
      edition.descriptions.collect{|description|
        description.user.username if description.user}.join(' ')
    }.join(' ')
  end
  
  def userfirstname
    self.editions.collect{|edition| 
      edition.descriptions.collect{|description|
        description.user.firstname if description.user}.join(' ')
    }.join(' ')
  end
  
  def userlastname
    self.editions.collect{|edition| 
      edition.descriptions.collect{|description|
        description.user.lastname if description.user}.join(' ')
    }.join(' ')
  end
  
  def text
    self.editions.collect{|edition| 
      edition.descriptions.collect{|description|
        description.text}.join(' ')
    }.join(' ')
  end
  
  def libraryname
    self.editions.collect{|edition| 
      edition.descriptions.collect{|description|
        description.user.library.name if description.user && description.user.library}.join(' ')
    }.join(' ')
  end
  
  def title_for_sort
    logger.error("title_for_sort: " + title)
    if self.title
      return self.title    
    else
      return ""
    end
  end
  
  def author_for_sort
    if self.authorlastname && self.authorlastname.length > 0
      authorname = self.authorlastname.downcase
      authorname = authorname + self.authorfirstname.downcase if self.authorfirstname
      returnauthor = authorname.gsub(/[^A-ZÅÄÖa-zåäö]/, '')
      logger.error("author_for_sort: " + returnauthor)
      return returnauthor
    else
      return "z"
    end
  end
  
  def year_for_sort
    max = self.editions.collect{ |edition| edition.year ? edition.year : -1 }.max()
    logger.error("year_for_sort: " + max.to_s)
    if max
      return max.to_s
    else 
      return "0"
    end
  end
  
  def date_for_sort
    max = self.editions.collect{|edition| 
      edition.descriptions.collect{|description|
        description.created_at ? description.created_at.to_i : -1}.max()
    }.max()
    logger.error("date_for_sort: " + max.to_s)
    if max
      return max.to_s
    else
      return "0"
    end
  end
  
  def save_and_index
    returnvalue = save
    ferret_update
    return returnvalue
  end
  
  def update_attributes_and_index(params)
    returnvalue = update_attributes(params)
    ferret_update
    return returnvalue
  end
  
  def dummy
    return "dummy"
  end
  
end
