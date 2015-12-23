Gyazo
=====
[Gyazo API](https://gyazo.com/api/docs) wrapper for Ruby

[![Build Status](https://travis-ci.org/masui/gyazo-ruby.svg?branch=master)](https://travis-ci.org/masui/gyazo-ruby)

- http://github.com/masui/gyazo-ruby
- https://rubygems.org/gems/gyazo


# Install


    % gem install gyazo


# Usage

Register new application and get [ACCESS TOKEN](https://gyazo.com/oauth/applications), then

### Upload

```ruby
require 'gyazo'

gyazo = Gyazo::Client.new 'your-access-token'
res = gyazo.upload 'my_image.png'
puts res['permalink_url']  # => "http://gyazo.com/a1b2cdef345"
```
#### Upload with metadata

```ruby
require 'gyazo'

gyazo = Gyazo::Client.new 'your-access-token'
res = gyazo.upload 'my_image.png',
  { 'time' => Time.now, 'url' => 'http://example.com/' }
puts res['permalink_url']
```

### List

```ruby
gyazo.list.each do |image|
  puts image['url']
end
```

### Delete

```ruby
gyazo.delete image_id
```


Test
----

setup

    % gem install bundler
    % bundle install
    % export GYAZO_TOKEN=a1b2cdef3456   ## set your API Token

run test

    % bundle exec rake test


Contributing
------------
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
