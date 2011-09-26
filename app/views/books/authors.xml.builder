xml.authors(:type => 'array') do
  for author in @authors
    xml.author do
      xml.firstname(author[0])    
      xml.lastname(author[1])    
    end
  end
end
