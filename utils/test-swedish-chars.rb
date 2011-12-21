# -*- encoding : utf-8 -*-
require 'rubygems'
require 'ferret'
 
#tell Ferret to be unicode-friendly. This unfortunately doesn't work on Windows.
Ferret.locale = "en_US.UTF-8"
puts "failed to set locale" if Ferret.locale.nil?
text = "Undergång Över Även"

include Ferret::Analysis

tokenizer = StandardAnalyzer.new.token_stream(:field, text)

while token = tokenizer.next
  puts token
end

