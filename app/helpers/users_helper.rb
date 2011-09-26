# -*- encoding : utf-8 -*-
# This code is licensed under the MIT license (see LICENSE file for details)
module UsersHelper

  def possible_roles
    roles = Role.all
    if @current_user.admin?
      return roles
    elsif @current_user.local_admin?
      roles.delete(admin)
      return roles
    else
      # Should never happen
      return []
    end
  end

  def possible_libraries
    libraries = Library.order("name")
    if @current_user.admin?
      return libraries
    elsif @current_user.local_admin?
      home_library =  libraries.detect{ |library| library.id == @current_user.library.id }
      return [ home_library ]
    else
      # Should never happen
      return []
    end
  end

end
