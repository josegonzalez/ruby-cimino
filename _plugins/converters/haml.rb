# Title: HamlConverter
# Source: https://gist.github.com/1098904
# Description: A Jekyll plugin to convert .haml to .html

require 'haml'

module Jekyll
  class HamlConverter < Converter
    safe true
    priority :low

    def matches(ext)
      ext =~ /haml/i
    end

    def output_ext(ext)
      ".html"
    end

    def convert(content)
      engine = Haml::Engine.new(content)
      engine.render
    end
  end
end