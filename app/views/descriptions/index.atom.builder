atom_feed(:url => formatted_description_url(:atom), :schema_date => @descriptions.first.created_at) do |feed|
  feed.title("Descriptions")
  feed.updated(@descriptions.first ? @descriptions.first.created_at : Time.now.utc)
  
  for description in @descriptions
    feed.entry(description) do |entry|
      
      entry.title(description.edition.book.title + " av "  + description.edition.book.authorfirstname + " " + description.edition.book.authorlastname) if description.edition && description.edition.book
      entry.content(description.text)
      
      entry.author do |author|
        author.name(description.user.firstname + " " + description.user.lastname) if description.user
      end
    end
  end
end