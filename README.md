Gyazo
=====
[Gyazo API](https://gyazo.com/api/docs) wrapper for Ruby

- http://github.com/gyazo/gyazo-ruby
- https://rubygems.org/gems/gyazo


# Install

    % gem install gyazo

# Usage

Register new application and get [ACCESS TOKEN](https://gyazo.com/oauth/applications), then

## Upload

```ruby
require 'gyazo'
gyazo = Gyazo::Client.new access_token: 'your-access-token'
res = gyazo.upload imagefile: 'my_image.png'
puts res #=> {:type=>"png", :thumb_url=>"https://thumb.gyazo.com/thumb/...", :created_at=>"2019-05-03T11:57:35+0000", :image_id=>"...", :permalink_url=>"https://gyazo.com/...", :url=>"https://i.gyazo.com/....png"}
```

### passing filename
if you give io for `imagefile:`, you need `filename:`.

```ruby
gyazo.upload imagefile: File.open(image), filename: 'image.png'
```

### Upload with metadata
Following attributes can be set

* created_at(default: `Time.now`)
* referer_url(default: '')
* title(default: '')
* desc(default: '')


```ruby
res = gyazo.upload imagefile: 'my_image.png', created_at: Time.now, referer_url: 'https://example.com/'
```

## List

```ruby
gyazo.list[:images].each do |image|
  puts image[:url]
end
```

## image detail

```ruby
gyazo.image image_id: image_id
```

## Delete

```ruby
gyazo.delete image_id: image_id
```


# Test

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
