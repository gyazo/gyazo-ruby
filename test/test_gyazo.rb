require File.expand_path 'test_helper', File.dirname(__FILE__)

class TestGyazo < MiniTest::Test
  GYAZO_REGEXP = %r{^https://gyazo\.com/[a-z\d]{32}$}

  def setup
    @gyazo = Gyazo::Client.new access_token: ENV['GYAZO_TOKEN']
    @imagefile = File.expand_path 'test.png', File.dirname(__FILE__)
  end

  def test_upload_filepath
    res = @gyazo.upload imagefile: @imagefile
    assert res[:permalink_url].match GYAZO_REGEXP
  end

  def test_upload_file
    res = @gyazo.upload imagefile: File.open(@imagefile), filename: 'test.png'
    assert res[:permalink_url].match GYAZO_REGEXP
  end

  def test_upload_with_collection_id
    res = @gyazo.upload imagefile: @imagefile, collection_id: ENV['GYAZO_COLLECTION_ID']
    assert res[:permalink_url].match GYAZO_REGEXP
  end

  def test_list
    list = @gyazo.list
    assert_instance_of Hash, list
    assert_instance_of Array, list[:images]
  end

  def test_delete
    res_up = @gyazo.upload imagefile: @imagefile
    res_del = @gyazo.delete image_id: res_up[:image_id]
    assert_equal res_del[:image_id], res_up[:image_id]
  end

  def test_image
    res_up = @gyazo.upload imagefile: @imagefile
    res = @gyazo.image image_id: res_up[:image_id]
    assert_equal res[:image_id], res_up[:image_id]
  end
end
