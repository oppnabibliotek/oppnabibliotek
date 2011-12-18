# -*- encoding : utf-8 -*-
# Load the rails application
require File.expand_path('../application', __FILE__)

# Make sure Ferret behaves for swedish characters etc
Ferret.locale = "en_US.UTF-8"

# Initialize the rails application
Openlibrary::Application.initialize!

