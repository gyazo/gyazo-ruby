require File.expand_path 'test_helper', File.dirname(__FILE__)

class TestGyazo < MiniTest::Test

  def setup
    @gyazo = Gyazo::Client.new ENV['GYAZO_TOKEN']
    @imagefile = File.expand_path 'test.png', File.dirname(__FILE__)
  end

  def test_upload
    res = @gyazo.upload @imagefile
    assert res['permalink_url'].match /^https?:\/\/gyazo.com\/[a-z\d]{32}$/i
  end

  def test_list
    assert_equal @gyazo.list.class, Array
  end

  def test_delete
    res_up = @gyazo.upload @imagefile
    res_del = @gyazo.delete res_up['image_id']
    assert_equal res_del['image_id'], res_up['image_id']
  end

end
