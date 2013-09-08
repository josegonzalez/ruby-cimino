# Title: SimpleFormatFilter
# Source: https://github.com/flatterline/jekyll-plugins/blob/master/simple_format.rb
# Description: This is a very simple Liquid Template filter to mimic the Rails simple_format method.
#              It will perform the following transformations:
#                - \r\n and \r -> \n
#                - 2+ newline -> paragraph
#                - 1 newline -> br
# Usage: {% if post.excerpt %} {{ post.excerpt | read_more: post.url | simple_format }} {% endif %}

module Jekyll
  module SimpleFormatFilter
    def simple_format(text)
      text = '' if text.nil?
      text = text.to_str

      text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
      text.gsub!(/\n\n+/, "</p>\n\n<p>")           # 2+ newline  -> paragraph
      text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') # 1 newline   -> br

      "<p>#{text}</p>"
    end
  end
end

Liquid::Template.register_filter(Jekyll::SimpleFormatFilter)
