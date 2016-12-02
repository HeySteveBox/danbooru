module Iqdb
  class Download
    attr_reader :source, :download, :matches

    def initialize(source)
      @source = source
    end

    def get_referer(url)
      headers = {}
      datums = {}

      Downloads::RewriteStrategies::Base.strategies.each do |strategy|
        url, headers, datums = strategy.new(url).rewrite(url, headers, datums)
      end

      [url, headers["Referer"]]
    end

    def find_similar
      if Danbooru.config.iqdbs_server
        url, ref = get_referer(source)
        params = {
          "key" => Danbooru.config.iqdbs_auth_key,
          "url" => url,
          "ref" => ref
        }
        uri = URI.parse("#{Danbooru.config.iqdbs_server}/similar")
        uri.query = URI.encode_www_form(params)

        Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.is_a?(URI::HTTPS)) do |http|
          resp = http.request_get(uri.request_uri)
          if resp.is_a?(Net::HTTPSuccess)
            json = JSON.parse(resp.body)
            if json.is_a?(Array)
              json
            else
              []
            end
          else
            raise "HTTP error code: #{resp.code} #{resp.message}"
          end
        end
      else
        begin
          tempfile = Tempfile.new("iqdb-#{$PROCESS_ID}")
          @download = Downloads::File.new(source, tempfile.path, :get_thumbnail => true)
          @download.download!

          if Danbooru.config.iqdb_hostname_and_port
            @matches = Iqdb::Server.default.query(3, @download.file_path).matches
          end
        ensure
          tempfile.close
          tempfile.unlink
        end
      end
    end
  end
end
