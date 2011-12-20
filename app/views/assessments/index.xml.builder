xml.assessments(:type => 'array') do
  xml.hitcount(@hitcount)
  xml.average_grade(@average) if @average
  for assessment in @assessments
    xml.assessment do
      xml.id(assessment.id)
      xml.user_id(assessment.user_id)
      xml.username(assessment.user.username)
      xml.book_id(assessment.book_id) if assessment.book_id
      xml.edition_id(assessment.edition_id) if assessment.edition_id
      xml.grade(assessment.grade)    
      xml.comment_header(assessment.comment_header)
      xml.comment_text(assessment.comment_text) 
      xml.published(assessment.published)
      xml.created_at(assessment.created_at) if assessment.created_at
      if assessment.book_id
        xml.book do
          xml.id(assessment.book.id)
          xml.title(assessment.book.title)
          xml.authorfirstname(assessment.book.authorfirstname)
          xml.authorlastname(assessment.book.authorlastname)
          xml.signum(assessment.book.signum_id)
        end
      end
      if assessment.edition_id
        xml.edition do
          xml.id(assessment.edition.id)
          xml.isbn(assessment.edition.isbn)
          xml.ssb_key(assessment.edition.ssb_key)
        end
      end
    end
  end
end
