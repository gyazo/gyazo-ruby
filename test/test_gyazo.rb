require File.expand_path 'test_helper', File.dirname(__FILE__)

class TestGyazo < MiniTest::Test

  def setup
    @gyazo = Gyazo::Client.new
    @imagefile = File.expand_path 'test.png', File.dirname(__FILE__)
    @image_id = Digest::MD5.hexdigest File.open(@imagefile).read
  end

  def test_upload
    url = @gyazo.upload @imagefile
    assert url.match /^#{@gyazo.host}\/[a-z\d]{32}$/
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
