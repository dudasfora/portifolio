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
        meta, self[:body] = File.read(@obj).split(/\r?\n\r?\n/, 2)

        # use the date from the filename, or else toto won't find the article
        @obj =~ /\/(\d{4}-\d{2}-\d{2})[^\/]*$/
        ($1 ? {:date => $1} : {}).merge(YAML.load(meta))
      elsif @obj.is_a? Hash
        @obj
      end.inject({}) {|h, (k,v)| h.merge(k.to_sym => v) }

      self.taint
      self.update data
      self[:date] = Date.parse(self[:date].gsub('/', '-')) rescue Date.today
      self
    end
  end

  class Site
    class Context

      def grid_class index
        return "first-line-entry" if index == 0 || index == 1 || index == 2

        if ((index + 1) % 4 == 0) || ((index + 1) % 5 == 0)
          "middle-entry-#{(index + 1).even? ? "even" : "odd"}"
        else
          "entry"
        end
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


