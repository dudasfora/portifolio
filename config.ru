require 'toto'

module Toto
  class Site
    class Context
      def to_html_without_layout(page)
        to_html page, @config
      end
    end
  end

  class Article
    def load
      data = if @obj.is_a? String
        # Windows usa \r\n ao invés de \n
        meta, self[:body] = File.read(@obj).gsub(/\r/, '').split(/\r?\n\r?\n/, 2)

        # use the date from the filename, or else toto won't find the article
        @obj =~ /\/(\d{4}-\d{2}-\d{2})[^\/]*$/
        ($1 ? {:date => $1} : {}).merge(YAML.load(meta))
      elsif @obj.is_a? Hash
        @obj
      end.inject({}) do |hash, (key, value)|
        new_key = if key.is_a?(String)
          # Caracter do mal do windows !.!
          key.codepoints.reject {|c| c == 65279}.pack("U*")
        else
          key
        end

        hash.merge(new_key.to_sym => value)
      end

      self.taint
      self.update data
      self[:date] = Date.parse(self[:date].gsub('/', '-')) rescue Date.today
      self
    end
  end

  class Site
    class Context

      def grid_class index
        @count ||= 0
        return "first-line-entry index-#{index + 1}" if index == 0 || index == 1 || index == 2

        if @count == 0
          @count += 1
          return "middle-entry-even"
        end

        if @count == 1
          @count += 1
          return "middle-entry-odd"
        end

        @count += 1
        @count = 0 if @count == 5
        "entry"
      end

    end
  end
end



# Rack config
use Rack::Static, :urls => ['/css', '/js', '/images', '/favicon.ico'], :root => 'public'
use Rack::CommonLogger

if ENV['RACK_ENV'] == 'development'
  use Rack::ShowExceptions
end

#
# Create and configure a toto instance
#
toto = Toto::Server.new do
  #
  # Add your settings here
  # set [:setting], [value]
  #
  set :author,    "dudasfora"                               # blog author
  set :title,     "Duda Asfora"                   # site title
  set :root,      "index"                                   # page to load on /
  set :date,      lambda {|now| now.strftime("%d/%m/%Y") }  # date format for articles
  # set :markdown,  :smart                                    # use markdown + smart-mode
  # set :disqus,    false                                     # disqus id, or false
  # set :summary,   :max => 150, :delim => /~/                # length of article summary and delimiter
  # set :ext,       'txt'                                     # file extension for articles
  # set :cache,      28800                                    # cache duration, in seconds

  set :date, lambda {|now| now.strftime("%B #{now.day.ordinal} %Y") }
end

run toto


