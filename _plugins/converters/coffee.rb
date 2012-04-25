# Title: CoffeeConverter
# Source: https://gist.github.com/959938
# Description: A Jekyll plugin to convert .coffee to .js

require 'coffee-script'

module Jekyll

  class CoffeeScriptConverter < Converter
    safe true
    priority :low

    def matches(ext)
      @enabled ? ext=~ /coffee/i : false
    end

    def output_ext(ext)
      ".js"
    end

    def convert(content)
      begin
        CoffeeScript.compile content
      rescue StandardError => e
        puts "CoffeeScript error:" + e.message
      end
    end
  end

end
