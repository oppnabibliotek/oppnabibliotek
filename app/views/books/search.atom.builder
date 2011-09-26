atom_feed(:url => formatted_book_url(:atom), :schema_date => @books.first.created_at) do |feed|
  feed.title("Books")
  feed.updated(@books.first ? @books.first.created_at : Time.now.utc)
  
  for book in @books
    feed.entry(book) do |entry|
      entry.title(book.title + " av "  + book.authorfirstname + " " + book.authorlastname)
      contentstring =""
      contentstring += "Target group: " + book.targetgroup.name if book.targetgroup
      contentstring +=" Age group: " + book.agegroup.name if book.agegroup
      entry.content(contentstring)  
     end
  end
end