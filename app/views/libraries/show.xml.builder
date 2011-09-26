xml.library do
  xml.bookinfolink(@library.bookinfolink)
  xml.county_id(@library.county.id) if @library.county
  xml.id(@library.id)
  xml.infolink(@library.infolink)
  xml.keep_isbn_dashes(@library.keep_isbn_dashes)
  xml.name(@library.name)
  xml.searchstring_encoding(@library.searchstring_encoding)
  xml.userinfolink(@library.userinfolink)
  xml.users(:type => 'array') do
    for user in @library.users do
      xml.user do
        xml.dynamicinfolink(user.dynamicinfolink)
        xml.firstname(user.firstname)
        xml.lastname(user.lastname)
        xml.id(user.id)
        xml.username(user.username)
      end
    end
  end
  #xml.departments(:type => 'array') do
  #  for department in @library.departments do
  #    xml.department do
  #      xml.id(department.id)
  #      xml.name(department.name)
  #      xml.ssbid(department.ssbid)
  #    end
  #  end
  #end
end
