$:.unshift File.expand_path '../lib', File.dirname(__FILE__)

require 'gyazo'

gyazo = Gyazo::Client.new(ENV['GYAZO_TOKEN'])

gyazo.list(:page => 1, :per_page => 5).each do |img|
  puts img['url']
end
