Gyazo
=====
Upload an image to http://gyazo.com

- http://github.com/masui/gyazo-ruby
- https://rubygems.org/gems/gyazo


Installation
------------

    % gem install gyazo


Usage
-----

### Upload

```ruby
require 'gyazo'

g = Gyazo::Client.new
g.upload 'my_image.png'  #=> "http://gyazo.com/a1b2cdef345"
```

### List

```ruby
g.list.each do |image|
   image['image_id']
end
```


### Upload to http://your-private-gyazo.com
```ruby
g = Gyazo::Client.new
g.host = 'http://your-private-gyazo.com'
g.upload 'my_image.png'
```

Test
----

    % gem install bundler
    % bundle install
    % bundle exec rake test


Contributing
------------
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
