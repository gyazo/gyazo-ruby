require File.expand_path 'test_helper', File.dirname(__FILE__)

class TestGyazo < MiniTest::Test

  def setup
    @gyazo = Gyazo::Client.new
    @imagefile = File.expand_path 'test.png', File.dirname(__FILE__)
    @image_id = "a2a2a8154340bd33e9cd5eeea1efd832"
  end

  def test_upload
    url = @gyazo.upload @imagefile
    assert_equal url, "#{@gyazo.host}/#{@image_id}"
  end

  def test_id
    @gyazo = Gyazo::Client.new
    assert @gyazo.id =~ /^[0-9a-f]+$/
    @gyazo.id = '12345'
    assert_equal @gyazo.id, '12345'
  end

  def test_list
    assert_equal @gyazo.list.class, Array
  end

  def test_info
    info = @gyazo.info @image_id
    assert_equal info.class, Hash
  end

end
