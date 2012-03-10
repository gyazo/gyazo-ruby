require File.dirname(__FILE__) + '/test_helper.rb'

class TestGyazo < Test::Unit::TestCase

  def setup
  end

  def test_upload
    imagefile = File.dirname(__FILE__) + '/test.png'
    g = Gyazo.new
    url = g.upload(imagefile)
    assert_equal(url,'http://gyazo.com/a2a2a8154340bd33e9cd5eeea1efd832.png')
  end
end
