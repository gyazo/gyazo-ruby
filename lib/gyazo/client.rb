# coding: utf-8
module Gyazo

  class Client

    attr_accessor :id, :user_id, :user_agent, :host

    def initialize(access_token = nil)
      @access_token = access_token
      @user_agent = "GyazoRubyGem/#{Gyazo::VERSION}"
    end
    
    def upload(imagefile,params={})
      url = "https://upload.gyazo.com/api/upload"
      time = params['time'] || params['created_at'] || Time.now
      res = HTTMultiParty.post url, {
        :query => {
          :access_token => @access_token,
          :imagedata => File.open(imagefile),
          :created_at => time.to_i,
          :referer_url => params['referer_url'] || params['url'] || '',
          :title =>  params['title'] || '',
          :desc =>  params['desc'] || ''
        },
        :header => {
          'User-Agent' => @user_agent
        }
      }
      raise Gyazo::Error, res.body unless res.code == 200
      return JSON.parse res.body
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
