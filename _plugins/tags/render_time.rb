# Title: RenderTimeTag
# Source: https://github.com/mojombo/jekyll/wiki/Plugins
# Description: Sample `render_time` tag

require 'yaml'

module Jekyll
  class RenderTimeTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @text = text
    end

    def render(context)
      "#{@text} #{Time.now}"
    end
  end
end

config = YAML.load_file(File.join(File.dirname(__FILE__), '..', '..', 'source', '_config.yml'))
if !config.key?("disabled_tags")
  Liquid::Template.register_tag('render_time', Jekyll::RenderTimeTag)
else
  disabled = config["disabled_tags"]
  disabled = [disabled] if disabled.is_a?('String')
  Liquid::Template.register_tag('render_time', Jekyll::RenderTimeTag) unless disabled.member?('render_time')
end
