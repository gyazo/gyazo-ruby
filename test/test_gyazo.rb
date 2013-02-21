require File.dirname(__FILE__) + '/test_helper.rb'

class TestGyazo < Test::Unit::TestCase

  def setup
  end

  def test_upload
    imagefile = File.dirname(__FILE__) + '/test.png'
    g = Gyazo.new
    url = g.upload(imagefile)
    assert_equal(url,'http://gyazo.com/6bdded98323cba83530daae7fa7881f9')
    # assert_equal(url,'http://gyazo.com/a2a2a8154340bd33e9cd5eeea1efd832')
  end

  def test_id
    g = Gyazo.new
    assert g.id =~ /^[0-9a-f]+$/
    g.id = '12345'
    assert g.id == '12345'
  end
end
