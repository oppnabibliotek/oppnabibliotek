# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
class SessionsController < ApplicationController

  skip_before_filter :check_authentication, :check_authorization

  ssl_required :new, :create, :destroy
  
  def new
  end

  def create
    begin
      user = User.authenticate(params[:login], params[:password])
    rescue Exception
      user = nil
    end
    if user
      session[:user_id] = user.id
      flash[:notice] = "Välkommen , #{user.username}!"
      redirect_to :controller => :users, :action => :usersearch
    else
      flash[:error] = "Ogiltig användare/lösenord!"
      render :action => 'new'
    end
  end

  def destroy
    reset_session
    flash[:notice] = "Du är utloggad."
    redirect_to new_session_url
  end

end
