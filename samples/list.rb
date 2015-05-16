$:.unshift File.expand_path '../lib', File.dirname(__FILE__)

require 'gyazo'

gyazo = Gyazo::Client.new(ENV['GYAZO_TOKEN'])

res = gyazo.list(:page => 1, :per_page => 50)

puts res[0]
puts res[0]['url']
