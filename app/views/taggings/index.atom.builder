atom_feed(:url => formatted_tagging_url(:atom), :schema_date => @taggings.first.created_at) do |feed|
  feed.title("Omdömen")
  feed.updated(@taggings.first ? @taggings.first.created_at : Time.now.utc)
  
  for tagging in @taggings
    feed.entry(tagging) do |entry|
      
      entry.title(tagging.book.title.to_s + " av "  + tagging.book.authorfirstname.to_s + " " + tagging.book.authorlastname.to_s) if tagging.book
      entry.content("Etikett: " + tagging.tag.name) if tagging.tag && tagging.tag.name
      entry.author do |author|
        author.name(tagging.user.firstname + " " + tagging.user.lastname) if tagging.user
      end
    end
  end
end
