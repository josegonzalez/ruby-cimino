# Title: ReadMoreFilter
# Source: https://github.com/flatterline/jekyll-plugins/blob/master/read_more.rb
# Description: This is a very simple Liquid Template filter to create a nofollow,
#              "read more" link for blog posts. It is intended to be used on blog
#              index pages after an excerpt.
# Usage: {% if post.excerpt %} {{ post.excerpt | read_more: post.url }} {% endif %}

module Jekyll
  module ReadMoreFilter
    def read_more(text, url)
      text = '' if text.nil?
      text = text.to_str

      "#{text}<a href=\"#{url}\" rel=\"nofollow\" class=\"read-more\">read more &raquo;</a>"
    end
  end
end

Liquid::Template.register_filter(Jekyll::ReadMoreFilter)
