Installation
============
Öppna Bibliotek (="Open Libraries") is a Ruby On Rails application that acts as an information hub for swedish libraries and other entities where "user generated content" can be shared, for example book reviews, assessments etc. Thus there is limited value in setting up multiple of these hubs - but for development purposes you need one on your own of course.


Server
------
ÖB is deployed on a Ubuntu LTS (10.04), 64 bit server. We suggest getting the ISO and fire it up in VirtualBox or similar. After that, try following the recipe below to get it all running - no promises though :)


Getting the git clone
---------------------

	sudo aptitude install git-core
	sudo mkdir /var/rails
	sudo chmod a+rw /var/rails
	cd /var/rails
	git clone https://github.com/oppnabibliotek/oppnabibliotek.git


Rails
-----
Getting Rails up and running takes a bit of work, this is the procedure we used.


RVM
---
	sudo aptitude install build-essential curl
	bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)
	. ~/.bashrc
	sudo aptitude install bison openssl libreadline6 libreadline6-dev zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev

Ruby 1.9.2
----------
	rvm install 1.9.2
	rvm --default use 1.9.2
	ruby -v
	ruby 1.9.2p290 (2011-07-09 revision 32553) [x86_64-linux]

Rails
-----
	sudo aptitude install rubygems
	sudo gem install rails
	rails -v
	Rails 3.1.0

MySQL
-----
	sudo aptitude install libmysqlclient16-dev
	sudo aptitude install mysql-server-5.1

Remember the password you picked :)


Apache2
-------
	sudo aptitude install apache2


Hostname
--------
I have been using "openlibrary.se" as the fake hostname for my virtualbox. I set this in /etc/hosts on the box itself:

	127.0.1.1	openlibrary www.openlibrary.se

...and this on the host machine:

	192.168.0.170 openlibrary www.openlibrary.se

...where that is the ip it ended up getting by VirtualBox, check what you have and substitute.


Passenger
---------
	sudo aptitude install libcurl4-openssl-dev apache2-prefork-dev libapr1-dev libaprutil1-dev ruby-dev

	gem install passenger
	passenger-install-apache2

This should show instructions on configuring apache2 (note that "someuser" below should be replaced with the user you are using). Create a file called /etc/apache2/mods-available/passenger.load with one line in it (check details with output from passenger-install-apache2):

	LoadModule passenger_module /home/someuser/.rvm/gems/ruby-1.9.2-p290/gems/passenger-3.0.9/ext/apache2/mod_passenger.so

Create the file /etc/apache2/mods-available/passenger.conf with the following 4 lines in it (again, check details with output from passenger-install-apace2):

	<IfModule passenger_module>
	PassengerRoot /home/someuser/.rvm/gems/ruby-1.9.2-p290/gems/passenger-3.0.9
	PassengerRuby /home/someuser/.rvm/wrappers/ruby-1.9.2-p290/ruby
	</IfModule>

Then we created /etc/apache2/sites-available/oppnabibliotek and oppnabibliotek-ssl, you can copy these from the git clone in etc/apache2/sites-available. After that we can enable modules and sites and restart to get it up. Finally we check status of passenger:

	sudo a2enmod passenger ssl
        sudo a2ensite oppnabibliotek oppnabibliotek-ssl
	sudo /etc/init.d/apache2 restart
	rvmsudo passenger-status

If all is fine it says something like:

	----------- General information -----------
	max      = 6
	count    = 0
	active   = 0
	inactive = 0
	Waiting on global queue: 0
	----------- Application groups -----------

Finally surfing to www.openlibrary.se should give us a fancy looking passenger error page with:

	"No such file or directory - /var/rails/oppnabibliotek/config/database.yml"

...which is perfectly correct for now. :)


Bundle
------
Now we are getting close. Rails 3 uses something called "bundle" to handle gems and other extra addons. It uses the Gemfile as input. Let's run it to download and install all extras we need:

	cd /var/rails/oppnabibliotek
	bundle install

This should end saying something like "Your bundle is complete!".


Database
--------
Now it is time to get MySQL up and running. First step is to create database.yml:

	cd /var/rails/oppnabibliotek
	cp config/database.yml.example config/database.yml

...and then edit it and set the password to whichever password you chose when you installed MySQL earlier.
Then we can do:

	rake db:setup

And surfing to http://www.openlibrary.se/books should say something about:

"A secret is required to generate an integrity hash for cookie session data. Use config.secret_token = "some secret phrase of at least 30 characters"in config/initializers/secret_token.rb"

	cp config/initializers/secret_token.rb.example config/initializers/secret_token.rb

...end edit it and set the secret random token. You probably need to restart apache to get an effect:

	sudo /etc/init.d/apache2 restart

After that http://www.openlibrary.se/books should work - although no books are listed :)


Getting ferret running as a background service
----------------------------------------------
There are some "post installation" tricks we need to do. Imagemagick may already be installed.

	sudo apt-get install imagemagick

The bundle command will run a post installation script for the "act_as_ferret" gem, creating a few scripts etc.

	bundle exec aaf_install

Now, in order for this "ferret" thingy to run as a service we have created an upstart service.
Copy etc/init/oppnabibliotek.conf to /etc/init. Edit it and replace "gokr" with the user you installed RVM/Ruby in.
Then start it using:

	sudo start oppnabibliotek

Check status:
	status oppnabibliotek


Finally this is to get "ferret" to work properly searching for books:

	rails console
	Book.rebuild_index


Are we done yet??
=================
We are basically done, but the database is empty. In order to really get going the database needs to be filled. We want to create a dummy database that can be used for testing, but we are not there yet.




Unit API test
=============
There are some API tests we can run to see that all is working. These are written in PHP so first we need some PHP stuff:

	apt-get install php5 phpunit php5-curl
	

Then we can be run the tests like this:

	cd /var/rails/oppnabibliotek
	phpunit apitest/apitest.php

These tests rely on dummy data to be loaded in the database, so they will not work at this point.
