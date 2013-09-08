# Title: RawTag
# Source: https://gist.github.com/1020852
# Description: Raw tag for jekyll. Keeps liquid from parsing text betweeen {% raw %} and {% endraw %}

module Jekyll
  class RawBlock < Liquid::Block
    def parse(tokens)
      @nodelist ||= []
      @nodelist.clear

      while token = tokens.shift
        if token =~ FullToken
          if block_delimiter == $1
            end_tag
            return
          end
        end
        @nodelist << token if not token.empty?
      end
    end
  end
end

config = YAML.load_file(File.join(File.dirname(__FILE__), '..', '..', 'source', '_config.yml'))
if !config.key?("disabled_tags")
  Liquid::Template.register_tag('raw', Jekyll::RawBlock)
else
  disabled = config["disabled_tags"]
  disabled = [disabled] if disabled.is_a?('String')
  Liquid::Template.register_tag('raw', Jekyll::RawBlock) unless disabled.member?('raw')
end
