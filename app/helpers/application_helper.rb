# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def current_user
    User.find(session[:user_id])
  end

#  def full_user_name
#    user = User.find(session[:user_id])
#    user.firstname + " " + user.lastname
#  end

end
