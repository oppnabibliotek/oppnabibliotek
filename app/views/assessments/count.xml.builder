xml.assessments do
  xml.count do
    xml.total(@total)
    xml.published(@published)
    xml.blacklisted(@blacklisted)
  end
end