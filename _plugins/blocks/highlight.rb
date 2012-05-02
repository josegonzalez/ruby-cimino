# Title: HighlightTag
# Author: Brandon Mathis http://brandonmathis.com
# Description: Write highlights with semantic HTML5 <figure> and <figcaption> elements and optional syntax highlighting — all with a simple, intuitive interface.
#
# Syntax:
# {% highlight [title] [url] [link text] %}
# code snippet
# {% endhighlight %}
#
# For syntax highlighting, put a file extension somewhere in the title. examples:
# {% highlight file.sh %}
# code snippet
# {% endhighlight %}
#
# {% highlight Time to be Awesome! (awesome.rb) %}
# code snippet
# {% endhighlight %}
#
# Example:
#
# {% highlight Got pain? painreleif.sh http://site.com/painreleief.sh Download it! %}
# $ rm -rf ~/PAIN
# {% endhighlight %}
#
# Output:
#
# <figure class='code'>
# <figcaption><span>Got pain? painrelief.sh</span> <a href="http://site.com/painrelief.sh">Download it!</a>
# <div class="highlight"><pre><code class="sh">
# -- nicely escaped highlighted code --
# </code></pre></div>
# </figure>
#
# Example 2 (no syntax highlighting):
#
# {% highlight %}
# <sarcasm>Ooooh, sarcasm... How original!</sarcasm>
# {% endhighlight %}
#
# <figure class='code'>
# <pre><code>&lt;sarcasm> Ooooh, sarcasm... How original!&lt;/sarcasm></code></pre>
# </figure>
#
require File.dirname(__FILE__) + '/../utilities/highlight_code'
require File.dirname(__FILE__) + '/../utilities/template_wrapper'

module Jekyll

  class EnhancedHighlightBlock < Liquid::Block
    include HighlightCode
    include TemplateWrapper

    CodeUrlTitle = /(\S[\S\s]*)\s+(https?:\/\/)(\S+)\s+(.+)/i
    CodeUrl = /(\S[\S\s]*)\s+(https?:\/\/)(\S+)/i
    Code = /(\S[\S\s]*)/

    def initialize(tag_name, markup, tokens)
      @title = nil
      @caption = nil
      @filetype = nil
      @highlight = true
      if markup =~ /\s*lang:(\w+)/i
        @filetype = $1
        markup = markup.sub(/lang:\w+/i,'')
      end
      if markup =~ CodeUrlTitle
        @file = $1
        @caption = "<figcaption><span>#{$1}</span><a href='#{$2 + $3}'>#{$4}</a></figcaption>"
      elsif markup =~ CodeUrl
        @file = $1
        @caption = "<figcaption><span>#{$1}</span><a href='#{$2 + $3}'>link</a></figcaption>"
      elsif markup =~ Code
        @file = $1
        @caption = "<figcaption><span>#{$1}</span></figcaption>\n"
      end
      if @file =~ /\S[\S\s]*\w+\.(\w+)/ && @filetype.nil?
        @filetype = $1
      end
      super
    end

    def render(context)
      output = super
      source = "<figure class='code'>"
      source += @caption if @caption
      if @filetype
        source += " #{highlight(output, @filetype)}</figure>"
      else
        source += "#{tableize_code(output.lstrip.rstrip.gsub(/</,'&lt;'))}</figure>"
      end
      source = safe_wrap(source)
      source = @plugin_config['prefix'] + source if @plugin_config['prefix']
      source = source + @plugin_config['suffix'] if @plugin_config['suffix']
      source
    end
  end

end

config = YAML.load_file(File.join(File.dirname(__FILE__), '..', '..', 'source', '_config.yml'))
if !config.key?("disabled_blocks")
  Liquid::Template.register_tag('highlight', Jekyll::EnhancedHighlightBlock)
else
  disabled = config["disabled_blocks"]
  disabled = [disabled] if disabled.is_a?('String')
  Liquid::Template.register_tag('highlight', Jekyll::EnhancedHighlightBlock) unless disabled.member?('highlight')
end
