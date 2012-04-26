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

config = YAML.load_file(File.join(File.dirname(__FILE__), '..', '..', 'source', '_config.yml'))
if !config.key?("disabled_blocks")
  Liquid::Template.register_tag('rainbow', Jekyll::RainbowBlock)
else
  disabled = config["disabled_blocks"]
  disabled = [disabled] if disabled.is_a?('String')
  Liquid::Template.register_tag('rainbow', Jekyll::RainbowBlock) unless disabled.member?('rainbow')
end
