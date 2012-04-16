xml.books(:type => 'array') do
  xml.hitcount(@hitcount)
  for book in @books
    if book.show_after_search
      xml.book do
        xml.id(book.id)
        xml.authorfirstname(book.authorfirstname)
        xml.authorlastname(book.authorlastname)
        xml.title(book.title)
        xml.reserved(book.reserved)
        xml.targetgroup_id(book.targetgroup.id) if book.targetgroup
        xml.targetgroup(book.targetgroup.name) if book.targetgroup
        xml.agegroup_id(book.agegroup.id) if book.agegroup
        xml.agegroup(book.agegroup.name) if book.agegroup
        xml.booktitle_part1(book.booktitle_part1)
        xml.booktitle_part2(book.booktitle_part2)
        xml.signum_id(book.signum.id) if book.signum
        xml.signum(book.signum.name) if book.signum
        xml.group_inst(book.group_inst)
        xml.created_at(book.created_at)
        xml.updated_at(book.updated_at)        
        if book.editions.size > 0
          xml.editions(:type => 'array') do
            for edition in book.editions
              if edition.show_after_search
                xml.edition do
                  xml.id(edition.id)
                  xml.isbn(edition.isbn)
                  xml.illustrator(edition.illustrator)
                  xml.year(edition.year)
                  xml.translator(edition.translator)
                  xml.imageurl(edition.imageurl)
                  xml.recordnr(edition.recordnr)
                  xml.recordcompany(edition.recordcompany)
                  xml.auxcreator(edition.auxcreator)
                  xml.ssb_key(edition.ssb_key)
                  xml.mediatype(edition.mediatype)
                  xml.mediatypecode(edition.mediatypecode)
                  xml.published(edition.published)
                  xml.created_at(edition.created_at)
                  xml.updated_at(edition.updated_at)
                  if edition.descriptions.size > 0
                    xml.descriptions(:type => 'array') do
                      for description in edition.descriptions
                        if description.show_after_search
                          xml.description do
                            xml.id(description.id)
                            xml.descriptiontext(description.text)
                            xml.user_id(description.user_id)
                            xml.username(description.user.username) if description.user
                            xml.userfirstname(description.user.firstname) if description.user
                            xml.userlastname(description.user.lastname) if description.user
                            xml.dynamicinfolink(description.user.dynamicinfolink) if description.user
                            xml.created_at(description.created_at)
                            xml.updated_at(description.updated_at)
                            xml.library_id(description.user.library.id) if description.user && description.user.library
                            xml.library(description.user.library.name) if description.user && description.user.library
                            xml.libraryinfolink(description.user.library.infolink)  if description.user && description.user.library
                            xml.userinfolink(description.user.library.userinfolink) if description.user && description.user.library
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end  
  end
end
