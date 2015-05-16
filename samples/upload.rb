$:.unshift File.expand_path '../lib', File.dirname(__FILE__)

require 'gyazo'

gyazo = Gyazo::Client.new(ENV['GYAZO_TOKEN'])

img_path = ARGV.shift

res = gyazo.upload(img_path)
puts res['url']
