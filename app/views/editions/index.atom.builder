atom_feed(:url => formatted_edition_url(:atom), :schema_date => @editions.first.created_at) do |feed|
  feed.title("Editions")
  feed.updated(@editions.first ? @editions.first.created_at : Time.now.utc)
  
  for edition in @editions
    feed.entry(edition) do |entry|
      
      entry.title(edition.isbn)
      entry.content("Isbn: " + edition.isbn)
      
      entry.author do |author|
        author.name(edition.book.authorfirstname + " " + edition.book.authorlastname) if edition.book
      end
    end
  end
end