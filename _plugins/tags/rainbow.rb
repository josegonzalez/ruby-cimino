# Title: RainbowTag
# Description: Wraps codeblocks in `rainbow` compliant html tags

module Jekyll
  class RainbowBlock < Liquid::Block
    def initialize(tag_name, markup, tokens)
      @lang = (markup =~ /lang:(\w+)/i) ? $1 : "generic"
      super
    end

    def render(context)
      output = super
      source = '<pre class="rainbow-code"><code data-language="' + @lang + '">' + output.lstrip.rstrip + '</code></pre>'
      source
    end
  end
end

Liquid::Template.register_tag('rainbow', Jekyll::RainbowBlock)