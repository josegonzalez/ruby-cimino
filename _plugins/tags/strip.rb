# Title: StripTag
# Source: https://github.com/aucor/jekyll-plugins/blob/master/strip.rb
# Description: Replaces multiple newlines and whitespace between them with one newline
# Usage: {% strip %}Content{% endstrip %}

module Jekyll
  class StripTag < Liquid::Block
    def render(context)
      return super if Liquid::Tag.disabled?(context, 'strip')

      super.gsub /\n\s*\n/, "\n"
    end
  end
end

Liquid::Template.register_tag('strip', Jekyll::StripTag)
