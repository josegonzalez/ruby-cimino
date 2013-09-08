# Title: ExtendedFilters
# Description: Some extra filters for liquid

require 'hpricot'
require 'nokogiri'
require 'multi_json'

module Liquid
  module ExtendedFilters
    def tokenize(input, second)
      stop_words = [
        "a", "about", "above", "after", "again", "against", "all", "am", "an",
        "and", "any", "are", "arent", "as", "at", "be", "because", "been",
        "before", "being", "below", "between", "both", "but", "by", "cant",
        "cannot", "could", "couldnt", "did", "didnt", "do", "does",
        "doesnt", "doing", "dont", "down", "during", "each", "few", "for",
        "from", "further", "had", "hadnt", "has", "hasnt", "have", "havent",
        "having", "he", "hed", "hell", "hes", "her", "here", "heres",
        "hers", "herself", "him", "himself", "his", "how", "hows", "i", "id",
        "ill", "im", "ive", "if", "in", "into", "is", "isnt", "it", "its",
        "its", "itself", "lets", "me", "more", "most", "mustnt", "my",
        "myself", "no", "nor", "not", "of", "off", "on", "once", "only", "or",
        "other", "ought", "our", "ours ", "ourselves", "out", "over", "own",
        "same", "shant", "she", "shed", "shell", "shes", "should",
        "shouldnt", "so", "some", "such", "than", "that", "thats",
        "the", "their", "theirs", "them", "themselves", "then", "there",
        "theres", "these", "they", "theyd", "theyll", "theyre",
        "theyve", "this", "those", "through", "to", "too", "under",
        "until", "up", "very", "was", "wasnt", "we", "wed", "well",
        "were", "weve", "were", "werent", "what", "whats", "when",
        "whens", "where", "wheres", "which", "while", "who", "whos",
        "whom", "why", "whys", "with", "wont", "would", "wouldnt", "you",
        "youd", "youll", "youre", "youve", "your", "yours", "yourself",
        "yourselves"
      ]
      a = input.downcase.delete("'").split(/\W+/)
      a += second.downcase.delete("'").split(/\W+/) unless second.nil?
      a.uniq.reject { |word| stop_words.include?(word) || word =~ /\A\d+\z/ }.sort
    end

    def titleize(input)
      input.gsub(/(\w+)/) {|s| s.capitalize}
    end

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
