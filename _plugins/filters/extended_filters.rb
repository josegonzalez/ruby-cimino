# Title: ExtendedFilters
# Description: Some extra filters for jekyll

require 'hpricot'
require 'nokogiri'
require 'multi_json'

module Liquid

  module ExtendedFilters

    def date_to_month(input)
      Date::MONTHNAMES[input]
    end

    def date_to_month_abbr(input)
      Date::ABBR_MONTHNAMES[input]
    end

    def padded_month(input)
      input.to_s.rjust(2, '0')
    end

    def date_to_utc(input)
      input.getutc
    end

    def to_json(input)
      MultiJson.dump(input)
    end

    def html_truncatewords(text, max_length = 200, ellipsis = "")
      ellipsis_length = ellipsis.length
      doc = Nokogiri::HTML::DocumentFragment.parse text
      content_length = doc.inner_text.length
      actual_length = max_length - ellipsis_length
      content_length > actual_length ? doc.truncate(actual_length).inner_html + ellipsis : text.to_s
    end

    def preview(text, delimiter = '<!-- end_preview -->')
      if text.index(delimiter) != nil
        text.split(delimiter)[0]
      else
        html_truncatewords(text)
      end
    end

    def markdownify(input)
      Markdown.new(input)
    end

  end

  module NokogiriTruncator

    module NodeWithChildren
      def truncate(max_length)
        return self if inner_text.length <= max_length
        truncated_node = self.dup
        truncated_node.children.remove

        self.children.each do |node|
          remaining_length = max_length - truncated_node.inner_text.length
          break if remaining_length <= 0
          truncated_node.add_child node.truncate(remaining_length)
        end
        truncated_node
      end
    end

    module TextNode
      def truncate(max_length)
        Nokogiri::XML::Text.new(content[0..(max_length - 1)], parent)
      end
    end

  end
  Nokogiri::HTML::DocumentFragment.send(:include, NokogiriTruncator::NodeWithChildren)
  Nokogiri::XML::Element.send(:include, NokogiriTruncator::NodeWithChildren)
  Nokogiri::XML::Text.send(:include, NokogiriTruncator::TextNode)

  Liquid::Template.register_filter(ExtendedFilters)
end
