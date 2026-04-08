# coding: utf-8
require 'optparse'
require 'json'
require 'time'
require 'fileutils'
require 'gyazo'

module Gyazo
  class CLI
    CONFIG_FILE = File.join(Dir.home, '.config', 'gyazo', 'config')

    def self.start(argv)
      new.run(argv)
    end

    def run(argv)
      global_options = {}
      global_parser = OptionParser.new do |opts|
        opts.banner = <<~BANNER
          Usage: gyazo [options] <command> [args]

          Commands:
            auth login              Save access token to config file
            auth logout             Remove access token from config file
            upload <file>           Upload an image
            list                    List images
            image <id>              Show image details
            delete <id>             Delete an image
            search <query>          Search images
            user                    Show user info
            version                 Show version

          Options:
        BANNER
        opts.on('-t', '--token TOKEN', 'Access token') { |t| global_options[:token] = t }
        opts.on('-f', '--format FORMAT', 'Output format: text (default) or json') { |f| global_options[:format] = f }
        opts.on_tail('-h', '--help', 'Show help') { puts opts; exit }
        opts.on_tail('-v', '--version', 'Show version') { puts Gyazo::VERSION; exit }
      end

      global_parser.order!(argv)
      command = argv.shift

      case command
      when 'auth'    then run_auth(argv, global_options)
      when 'upload'  then run_upload(argv, global_options)
      when 'list'    then run_list(argv, global_options)
      when 'image'   then run_image(argv, global_options)
      when 'delete'  then run_delete(argv, global_options)
      when 'search'  then run_search(argv, global_options)
      when 'user'    then run_user(argv, global_options)
      when 'version' then puts Gyazo::VERSION
      when nil
        warn global_parser
        exit 1
      else
        warn "Unknown command: #{command}\n\n#{global_parser}"
        exit 1
      end
    rescue Gyazo::Error => e
      warn "Error: #{e.message}"
      exit 1
    end

    private

    def client(options)
      token = resolve_token(options)
      abort "No access token. Set GYAZO_ACCESS_TOKEN or run 'gyazo auth login'" unless token
      Gyazo::Client.new(access_token: token)
    end

    def resolve_token(options)
      options[:token] || ENV['GYAZO_ACCESS_TOKEN'] || load_token
    end

    def load_token
      return nil unless File.exist?(CONFIG_FILE)
      File.foreach(CONFIG_FILE) do |line|
        return $1.strip if line =~ /\Aaccess_token=(.+)/
      end
      nil
    end

    def save_token(token)
      FileUtils.mkdir_p(File.dirname(CONFIG_FILE))
      File.write(CONFIG_FILE, "access_token=#{token}\n")
      File.chmod(0o600, CONFIG_FILE)
    end

    def run_auth(argv, _options)
      subcommand = argv.shift
      case subcommand
      when 'login'
        puts 'Create a token at https://gyazo.com/oauth/applications'
        print 'Enter your Gyazo access token: '
        token = $stdin.gets&.chomp
        abort 'Cancelled' if token.nil? || token.empty?
        save_token(token)
        puts "Token saved to #{CONFIG_FILE}"
      when 'logout'
        if File.exist?(CONFIG_FILE)
          File.delete(CONFIG_FILE)
          puts 'Token removed'
        else
          puts 'No token found'
        end
      else
        warn 'Usage: gyazo auth <login|logout>'
        exit 1
      end
    end

    def run_upload(argv, options)
      upload_opts = {}
      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: gyazo upload [options] <file>'
        opts.on('--title TITLE', 'Image title') { |v| upload_opts[:title] = v }
        opts.on('--description DESC', 'Image description') { |v| upload_opts[:desc] = v }
        opts.on('--collection-id ID', 'Collection ID') { |v| upload_opts[:collection_id] = v }
        opts.on('--created-at DATETIME', 'Created at (ISO 8601)') { |v| upload_opts[:created_at] = Time.parse(v) }
      end
      parser.parse!(argv)

      file = argv.shift
      abort parser.to_s unless file
      abort "File not found: #{file}" unless File.file?(file)

      result = client(options).upload(imagefile: file, **upload_opts)
      output(result, options)
    end

    def run_list(argv, options)
      list_opts = {}
      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: gyazo list [options]'
        opts.on('--page N', Integer, 'Page number (default: 1)') { |v| list_opts[:page] = v }
        opts.on('--per-page N', Integer, 'Per page (default: 20)') { |v| list_opts[:per_page] = v }
      end
      parser.parse!(argv)

      result = client(options).list(**list_opts)

      if options[:format] == 'json'
        puts JSON.pretty_generate(result)
      else
        puts "Total: #{result[:total_count]}  Page: #{result[:current_page]}  Per page: #{result[:per_page]}"
        puts
        result[:images].each do |img|
          puts "#{img[:image_id]}  #{img[:permalink_url]}"
          title = img.dig(:metadata, :title)
          puts "  #{title}" unless title.nil? || title.empty?
          puts "  #{img[:created_at]}" if img[:created_at]
        end
      end
    end

    def run_image(argv, options)
      id = argv.shift
      abort 'Usage: gyazo image <id>' unless id
      output(client(options).image(image_id: id), options)
    end

    def run_delete(argv, options)
      id = argv.shift
      abort 'Usage: gyazo delete <id>' unless id
      result = client(options).delete(image_id: id)
      if options[:format] == 'json'
        puts JSON.pretty_generate(result)
      else
        puts "Deleted: #{result[:image_id]}"
      end
    end

    def run_search(argv, options)
      search_opts = {}
      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: gyazo search [options] <query>'
        opts.on('--page N', Integer, 'Page number (default: 1)') { |v| search_opts[:page] = v }
        opts.on('--per-page N', Integer, 'Per page (default: 20)') { |v| search_opts[:per_page] = v }
      end
      parser.parse!(argv)

      query = argv.shift
      abort parser.to_s unless query

      result = client(options).search(query:, **search_opts)
      if options[:format] == 'json'
        puts JSON.pretty_generate(result)
      else
        result.each do |img|
          puts "#{img[:image_id]}  #{img[:permalink_url]}"
          title = img.dig(:metadata, :title)
          puts "  #{title}" unless title.nil? || title.empty?
        end
      end
    end

    def run_user(argv, options)
      output(client(options).user_info, options)
    end

    def output(data, options)
      if options[:format] == 'json'
        puts JSON.pretty_generate(data)
      else
        print_hash(data)
      end
    end

    def print_hash(hash, indent = 0)
      hash.each do |k, v|
        if v.is_a?(Hash)
          puts "#{' ' * indent}#{k}:"
          print_hash(v, indent + 2)
        elsif v.is_a?(Array)
          puts "#{' ' * indent}#{k}: [#{v.length} items]"
        else
          puts "#{' ' * indent}#{k}: #{v.to_s.gsub(/\r?\n/, '\n')}"
        end
      end
    end
  end
end
