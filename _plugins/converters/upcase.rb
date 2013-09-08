# Title: UpcaseConverter
# Source: https://github.com/mojombo/jekyll/wiki/Plugins
# Description: Uppercase ALL the things

module Jekyll
  class UpcaseConverter < Converter
    safe true
    priority :low

    def matches(ext)
      @enabled ? ext =~ /upcase/i : false
    end

    def output_ext(ext)
      ".html"
    end

    def convert(content)
      content.upcase
    end
  end
end
