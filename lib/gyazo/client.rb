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

      parse_body(res)[:json]
    end

    def list(page: 1, per_page: 20)
      r = send_get(path: '/api/images', params: { page:, per_page: })
      res = r[:response]
      {
        total_count: res.headers['X-Total-Count'],
        current_page: res.headers['X-Current-Page'],
        per_page: res.headers['X-Per-Page'],
        user_type: res.headers['X-User-Type'],
        images: r[:json],
      }
    end

    def image(image_id:)
      send_get(path: "/api/images/#{image_id}")[:json]
    end

    def delete(image_id:)
      send_delete(path: "/api/images/#{image_id}")[:json]
    end

    def user_info
      send_get(path: '/api/users/me')[:json]
    end

    def search(query:, page: 1, per_page: 20)
      send_get(path: '/api/search', params: { query:, page:, per_page: })[:json]
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

    def send_req(method:, path:, params: {})
      res = @conn.send(method) do |req|
        req.url path
        req.params[:access_token] = @access_token
        params.each do |k, v|
          req.params[k] = v
        end
        req.headers['User-Agent'] = @user_agent
      end

      parse_body(res)
    end

    def send_get(path:, params: {})
      send_req(method: :get, path:, params:)
    end

    def send_delete(path:, params: {})
      send_req(method: :delete, path:, params:)
    end

    def parse_body(res)
      raise Gyazo::Error, res.body unless res.status == 200
      begin
        json = ::JSON.parse res.body, symbolize_names: true
      rescue ::JSON::ParserError => e
        raise Gyazo::Error, "Gyazo API response is not JSON: #{e.message}, body: #{res.body}"
      end
      { json:, response: res }
    end
  end
end
