# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
# == Schema Information
# Schema version: 20110908101555
#
# Table name: users
#
#  id              :integer(4)      not null, primary key
#  username        :string(255)
#  password_hash   :string(255)
#  firstname       :string(255)
#  lastname        :string(255)
#  email           :string(255)
#  library_id      :integer(4)
#  temp_userid     :integer(4)
#  dynamicinfolink :string(255)
#  alias           :string(255)
#  foreign_id      :string(255)
#

# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  has_and_belongs_to_many :roles
  belongs_to :library
  has_many :descriptions
  has_many :assessments, :dependent => :delete_all
  has_and_belongs_to_many :departments
  has_many :taggings, :dependent => :delete_all
  has_many :tags, :through => :taggings
  
  before_save :remove_blanks
  
  validates_uniqueness_of :username, :message => 'är redan upptaget'
  
  validates_format_of :email,
  :with => %r{.+@.+\..+},
  :allow_nil => true,
  :allow_blank => true,
  :message => "har fel format"
  
  def remove_blanks
    self.username = self.username.strip
  end
  
  def password=(pass)
    self.password_hash = Digest::MD5.hexdigest(pass) if pass && pass != ""
  end

  def password
  end

  def full_user_name
    firstname + " " + lastname
  end

  def self.authenticate(username, password)
    user = User.where("username = ?" , username).first
    if user.blank? || Digest::MD5.hexdigest(password) != user.password_hash
      raise "Username or password invalid"
    end
    user
  end

  def admin?
    roles.where(:id => Role.admin).exists?
  end

  def local_admin?
    roles.where(:id => Role.local_admin).exists?
  end

  def writer?
    roles.where(:id => Role.writer).exists?
  end

  def member?
    roles.where(:id => Role.member).exists?
  end

  def moreThanMember?
    roles.where(:id => Role.moreThanMember).exists?
  end
end
