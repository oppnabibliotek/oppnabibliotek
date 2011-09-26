xml.taggings(:type => 'array') do
  xml.hitcount(@hitcount)
  for tagging in @taggings
    xml.tagging do
      xml.id(tagging.id)
      xml.user_id(tagging.user_id)
      xml.username(tagging.user.username)
      xml.book_id(tagging.book_id) if tagging.book_id
      xml.edition_id(tagging.edition_id) if tagging.edition_id
      xml.published(tagging.published)
      xml.tag do
        xml.id(tagging.tag.id)
        xml.name(tagging.tag.name)
      end
      if tagging.book_id
        xml.book do
          xml.id(tagging.book.id)
          xml.title(tagging.book.title)
          xml.authorfirstname(tagging.book.authorfirstname)
          xml.authorlastname(tagging.book.authorlastname)
          xml.signum(tagging.book.signum_id)
        end
      end
      if tagging.edition_id
        xml.edition do
          xml.id(tagging.edition.id)
          xml.isbn(tagging.edition.isbn)
        end
      end
    end
  end
end