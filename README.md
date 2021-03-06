# staplegun

Easily post new pins to your Pinterest boards

## Installation

`$ gem install staplegun` or add it to your `Gemfile`:

```ruby
  gem 'staplegun'
```

## Usage

```ruby
  require 'staplegun'

  stapler = Staplegun.new :email => "your.pinterest.account@email.com", :password => "pinterest_password"
  stapler.pin {
    :board_id => "12345678910",
    :link => "http://some-awesome-website.com",
    :image_url => "http://some-awesome-website.com/badass-image.png",
    :description => "Awesome & Badass!"
  }  
```

## Contributing to staplegun

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2013 Ben Sheldon. See LICENSE.txt for further details.

