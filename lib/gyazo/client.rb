module Gyazo

  class Client

    attr_accessor :id, :user_id, :user_agent, :host

    def initialize(access_token = nil)
      @access_token = access_token
      @user_agent = "GyazoRubyGem/#{Gyazo::VERSION}"
    end
    
    def upload(imagefile,time=nil)
      url = "https://upload.gyazo.com/api/upload"
      res = HTTMultiParty.post url, {
        :query => {
          :access_token => @access_token,
          :imagedata => File.open(imagefile)
        },
        :header => {
          'User-Agent' => @user_agent
        }
      }
      raise Gyazo::Error, res.body unless res.code == 200
      return JSON.parse res.body
    end

    def upload_new(imagefile,time=nil)
      url = "https://upload.gyazo.com/upload.cgi"
      time = Time.now unless time
      res = HTTMultiParty.post url, {
        :query => {
          :access_token => @access_token,
          :imagedata => File.open(imagefile),
          :created_at => time.to_i * 1000
        },
        :header => {
          'User-Agent' => @user_agent
        }
      }
      puts res
      raise Gyazo::Error, res.body unless res.code == 200
      url = res.body
      url =~ /[0-9a-f]{32}/
      id = $&
      puts url
      puts id
      { # upload.cgiを使った場合、無理矢理JSONぽいのを生成する
        "image_id" => id,
        "permalink_url" => "http://gyazo.com/#{id}",
        "url" => "https://i.gyazo.com/#{id}.png",
        "type" => "png"
      }
    end

    def list(query = {})
      url = "https://api.gyazo.com/api/images"
      query[:access_token] = @access_token
      res = HTTParty.get url, {
        :query => query,
        :header => {
          'User-Agent' => @user_agent
        }
      }
      raise Gyazo::Error, res.body unless res.code == 200
      return JSON.parse res.body
    end

    def delete(image_id)
      url = "https://api.gyazo.com/api/images/#{image_id}"
      res = HTTParty.delete url, {
        :query => {
          :access_token => @access_token
        }
      }
      raise Gyazo::Error, res.body unless res.code == 200
      return JSON.parse res.body
    end
  end
end
