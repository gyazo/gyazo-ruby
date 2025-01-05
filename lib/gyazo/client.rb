# coding: utf-8
require 'json'
require 'faraday'
require 'mime/types'

module Gyazo
  class Client
    UploadURI = 'https://upload.gyazo.com/api/upload'
    APIHost = 'https://api.gyazo.com'
    attr_accessor :access_token, :user_agent

    def initialize(access_token:, user_agent: nil)
      @access_token = access_token
      @user_agent = user_agent || "GyazoRubyGem/#{Gyazo::VERSION}"
      @conn = ::Faraday.new(url: APIHost) do |f|
        f.request :url_encoded
        f.adapter ::Faraday.default_adapter
      end
    end

    def upload(imagefile:, filename: nil, created_at: ::Time.now, referer_url: '', title: '', desc: '', collection_id: '')
      ensure_io_or_file_exists imagefile, filename

      conn = ::Faraday.new do |f|
        f.request :multipart
        f.request :url_encoded
        f.adapter ::Faraday.default_adapter
      end
      type = ::MIME::Types.type_for(filename || imagefile)[0].to_s
      res = conn.post UploadURI do |req|
        req.body = {
          access_token: @access_token,
          imagedata: ::Faraday::UploadIO.new(imagefile, type, filename),
          created_at: created_at.to_i,
          referer_url: referer_url.to_s,
          title: title.to_s,
          desc: desc.to_s,
          collection_id: collection_id.to_s,
        }
        req.headers['User-Agent'] = @user_agent
      end
      raise Gyazo::Error, res.body unless res.status == 200
      return ::JSON.parse res.body, symbolize_names: true
    end

    def list(page: 1, per_page: 20)
      path = '/api/images'
      res = @conn.get path do |req|
        req.params[:access_token] = @access_token
        req.params[:page] = page
        req.params[:per_page] = per_page
        req.headers['User-Agent'] = @user_agent
      end
      raise Gyazo::Error, res.body unless res.status == 200
      json = ::JSON.parse res.body, symbolize_names: true
      {
        total_count: res.headers['X-Total-Count'],
        current_page: res.headers['X-Current-Page'],
        per_page: res.headers['X-Per-Page'],
        user_type: res.headers['X-User-Type'],
        images: json
      }
    end

    def image(image_id:)
      path = "/api/images/#{image_id}"
      send_get_without_param(path:)
    end

    def delete(image_id:)
      path = "/api/images/#{image_id}"
      res = @conn.delete path do |req|
        req.params[:access_token] = @access_token
        req.headers['User-Agent'] = @user_agent
      end
      raise Gyazo::Error, res.body unless res.status == 200
      return ::JSON.parse res.body, symbolize_names: true
    end

    def user_info
      path = '/api/users/me'
      send_get_without_param(path:)
    end

    private

    def ensure_io_or_file_exists(file, name)
      if file.respond_to?(:read) && file.respond_to?(:rewind)
        if name.nil?
          raise ArgumentError, "need filename: when file is io"
        end
        return
      end
      return if ::File.file? file
      raise ArgumentError, "cannot find file #{file}"
    end

    def send_get_without_param(path:)
      res = @conn.get path do |req|
        req.params[:access_token] = @access_token
        req.headers['User-Agent'] = @user_agent
      end
      raise Gyazo::Error, res.body unless res.status == 200
      return ::JSON.parse res.body, symbolize_names: true
    end
  end
end
