atom_feed(:url => formatted_assessment_url(:atom), :schema_date => @assessments.first.created_at) do |feed|
  feed.title("Omdömen")
  feed.updated(@assessments.first ? @assessments.first.created_at : Time.now.utc)
  
  for assessment in @assessments
    feed.entry(assessment) do |entry|
      
      entry.title(assessment.book.title + " av "  + assessment.book.authorfirstname + " " + assessment.book.authorlastname) if assessment.book
      entry.content("Betyg: " + assessment.grade.to_s + ", Omdömestitel: " + assessment.comment_header + ", Omdömestext: " + assessment.comment_text)
      entry.author do |author|
        author.name(assessment.user.firstname + " " + assessment.user.lastname) if assessment.user
      end
    end
  end
end
