module Gyazo

  class Client

    attr_accessor :id, :user_id, :user_agent, :host

    def initialize(user_id=nil)
      @user_id = user_id
      @user = ENV['USER']
      @idfile = "#{ENV['HOME']}/Library/Gyazo/id"
      @id = nil
      @id = File.read(@idfile).strip if File.exist? @idfile
      @user_agent = "GyazoRubyGem/#{Gyazo::VERSION}"
      @host = 'http://gyazo.com'
    end

    def info(image_id)
      res = HTTParty.get "#{@host}/api/image/get", {
        :query => {
          :image_id => image_id
        },
        :header => {
          'User-Agent' => @user_agent
        }
      }

      raise Gyazz::Error, res.body unless res.code == 200
      JSON.parse(res.body)
    end

    def list(page=1, count=100)
      url = "#{@host}/api/image/list"
      query = {:page => page, :count => count}
      if @user_id
        query[:user_id] = @user_id
      else
        query[:device_id] = @id
      end

      res = HTTParty.get "#{@host}/api/image/list", {
        :query => query,
        :header => {
          'User-Agent' => @user_agent
        }
      }

      raise Gyazz::Error, res.body unless res.code == 200
      JSON.parse(res.body)['images']
    end

    DEFAULT_UPLOAD_OPTS = {:time => nil, :raw => false}
    def upload(imagefile, opts={})
      DEFAULT_UPLOAD_OPTS.each do |k,v|
        opts[k] = v unless opts.include? k
      end

      unless opts[:raw]
        tmpfile = "/tmp/gyazo_upload_#{Time.now.to_i}_#{Time.now.usec}.png"
        if File.exist? imagefile
          system "sips -s format png \"#{imagefile}\" --out \"#{tmpfile}\" > /dev/null"
        end
      end

      res = HTTMultiParty.post "#{@host}/upload.cgi", {
        :query => {
          :id => @id,
          :imagedata => File.new(imagefile)
        },
        :header => {
          'User-Agent' => @user_agent
        }
      }

      File.delete(tmpfile) if tmpfile and File.exists? tmpfile

      raise Gyazo::Error, res.body unless res.code == 200
      res.body
    end

  end
end
