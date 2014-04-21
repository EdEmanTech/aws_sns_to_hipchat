AWS SNS to HipChat
==================

A lightweight Sinatra service which sends AWS SNS notifications to HipChat

##To Install
git clone the repo to your server.
`git clone https://github.com/EdEmanTech/aws_sns_to_hipchat.git `

##To Run
Assuming you have ruby installed, just run bundler
`gem install bundler`

Then `bundle install`

And finally to Start the Service `RACK_ENV=production ruby aws_sns_to_hipchat.rb -p <PORT NUMBER>`

Todo:
Add an upstart script.
Add some real logging.
Change the json parsing to allow new parsing sections that we get added to a collection of parsing rules to run through... you know, More Open/Closed principle ;)

Please submit pull requests, happy to hear feedback.

Copyright (c) 2014 Emmanuel Acheampong
