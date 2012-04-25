# Title: SassConverter
# Source: https://gist.github.com/1942866
# Description: A Jekyll plugin to convert .sass to .css

require 'sass'

module Jekyll

  class SassConverter < Converter
    safe true
    priority :low

    attr_accessor :sass_style

    def matches(ext)
      return false if !@enabled

      if ext =~ /sass/i
        @sass_syntax = :sass
      elsif ext =~ /scss/i
        @sass_syntax = :scss
      else
        false
      end
    end

    def output_ext(ext)
      ".css"
    end

    def convert(content)
      engine = Sass::Engine.new(content, :syntax => @sass_syntax)
      engine.render
    end
  end

end
