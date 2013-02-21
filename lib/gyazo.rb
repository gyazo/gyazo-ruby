# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'net/http'
require 'json'

class Gyazo
  VERSION = '0.2.0'

  def initialize(app = '/Applications/Gyazo.app')
    @user = IO.popen("whoami", "r+").gets.chomp
    @program = app
    @idfile = "/Users/#{@user}/Library/Gyazo/id"
    @old_idfile = File.dirname(@program) + "/gyazo.app/Contents/Resources/id"
    @id = ''
    if File.exist?(@idfile) then
      @id = File.read(@idfile).chomp
    elsif File.exist?(@old_idfile) then
      @id = File.read(@old_idfile).chomp
    end
    @host = 'gyazo.com'
  end

  attr_accessor :id

  def info(gyazoid)
    gyazoid =~ /[0-9a-f]{32}/
    gyazoid = $&
    cgi = "/api/image/get?image_id=#{gyazoid}"
    header = {}
    res = Net::HTTP.start(@host,80){|http|
      http.get(cgi,header)
    }
    JSON.parse(res.read_body)
  end

  def list(page,count)
    cgi = "/api/image/list?userkey=#{@id}&page=#{page}&count=#{count}"
    header = {}
    res = Net::HTTP.start(@host,80){|http|
      http.get(cgi,header)
    }
    JSON.parse(res.read_body)['images']
  end

  def upload(imagefile,time=nil)
    tmpfile = "/tmp/image_upload#{$$}.png"
    if imagefile && File.exist?(imagefile) then
      system "sips -s format png \"#{imagefile}\" --out \"#{tmpfile}\" > /dev/null"
    end
    imagedata = File.read(tmpfile)
    File.delete(tmpfile)

    boundary = '----BOUNDARYBOUNDARY----'
    @cgi = '/upload.cgi'
    @ua   = 'Gyazo/1.0'
    data = <<EOF
--#{boundary}\r
content-disposition: form-data; name="id"\r
\r
#{@id}\r
--#{boundary}\r
content-disposition: form-data; name="imagedata"; filename="gyazo.com"\r
\r
#{imagedata}\r
--#{boundary}--\r
EOF

    if time && time.class == Time then
      @timestr = time.gmtime.strftime("%Y-%m-%d %H:%M:%S")
      s = <<EOF
--#{boundary}\r
content-disposition: form-data; name="date"\r
\r
#{@timestr}\r
EOF
      data = s + data
    end

    header ={
      'Content-Length' => data.length.to_s,
      'Content-type' => "multipart/form-data; boundary=#{boundary}",
      'User-Agent' => @ua
    }
    res = Net::HTTP.start(@host,80){|http|
      http.post(@cgi,data,header)
    }

    @url = res.read_body

    # save id
    newid = res['X-Gyazo-Id']
    if newid and newid != "" then
      if !File.exist?(File.dirname(@idfile)) then
        Dir.mkdir(File.dirname(@idfile))
      end
      if File.exist?(@idfile) then
        File.rename(@idfile, @idfile+Time.new.strftime("_%Y%m%d%H%M%S.bak"))
      end
      File.open(@idfile,"w").print(newid)
      if File.exist?(@old_idfile) then
        File.delete(@old_idfile)
      end
    end
    @url
  end

end
