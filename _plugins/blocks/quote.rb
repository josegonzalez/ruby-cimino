# Title: QuoteTag
# Source: God Knows where
# Description: Blockquote and Pullquote tags

module Jekyll

  # Outputs a string with a given attribution as a quote
  #
  #   {% blockquote John Paul Jones %}
  #     Monkeys!
  #   {% endblockquote %}
  #   ...
  #   <blockquote>
  #     Monkeys!
  #     <br />
  #     <strong>John Paul Jones</strong>
  #   </blockquote>
  #
  class BlockquoteBlock < Liquid::Block
    TitledCitation = /(\S.*)\s+(https?:\/\/)(\S+)\s+(.+)/i
    Citation = /(\S.*)\s+(https?:\/\/)(\S+)/i
    Author = /([\w\s]+)/

    def initialize(tag_name, markup, tokens)
      @class = ''
      @by = nil
      @source = nil
      @title = nil
      if markup =~ TitledCitation
        @by = $1
        @source = $2 + $3
        @title = $4
      elsif markup =~ Citation
        @by = $1
        @source = $2 + $3
      elsif markup =~ Author
        @by = $1
      end
      super
    end

    def render(context)
      output = super
      parts = ['<blockquote' + @class + '>', output]
      parts << '<strong class="quote-by">' + @by + '</strong>' if @by
      if @source.nil? && @title.nil?
        parts << '</blockquote>'
        return parts.join("\n")
      end

      if !@source.nil?
        cite = "<cite><a href='#{@source}'>#{(@title || source)}</a></cite>"
      elsif !@title.nil?
        cite = "<cite>#{@title}</cite>"
      end

      parts << cite if cite
      parts << '</blockquote>'
      parts
    end
  end

  # Outputs a string with a given attribution as a pullquote
  #
  #   {% pullquote John Paul Jones %}
  #     Monkeys!
  #   {% endpullquote %}
  #   ...
  #   <blockquote class="pullquote">
  #     Monkeys!
  #     <br />
  #     <strong>John Paul Jones</strong>
  #   </blockquote>
  #
  class PullquoteBlock < BlockquoteBlock
    def render(context)
      @class = ' class="pullquote"'
      super(context)
    end
  end

end

config = YAML.load_file(File.join(File.dirname(__FILE__), '..', '..', 'source', '_config.yml'))
if !config.key?("disabled_blocks")
  Liquid::Template.register_tag('blockquote', Jekyll::BlockquoteBlock)
  Liquid::Template.register_tag('pullquote', Jekyll::PullquoteBlock)
else
  disabled = config["disabled_blocks"]
  disabled = [disabled] if disabled.is_a?('String')
  Liquid::Template.register_tag('blockquote', Jekyll::BlockquoteBlock) unless disabled.member?('blockquote')
  Liquid::Template.register_tag('pullquote', Jekyll::PullquoteBlock) unless disabled.member?('pullquote')
end
