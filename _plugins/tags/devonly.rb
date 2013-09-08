# Title: DevOnlyTag
# Source: https://gist.github.com/moshen/2403522
# Description: Show content only when in dev mode
#
# Jekyll Dev Only Tag
#
# Author : Colin Kennedy
# Usage  :
#
#  The markup/script/css included within the `devonly` tags
#  is included in the rendered page when either:
#
#  * `server` mode is used
#  * A top level `dev` key is `true` in `_config.yml`
#
#  Examples:
#
#  For dealing with something like Disqus:
#
#      <script>
#        dosomedisqusstuff();
#
#        {% devonly %}
#        var developer = 1;
#        {% enddevonly %}
#      </script>
#
#  Include a debug script tag:
#
#      {% devonly %}
#      <script type="text/javascript" src="/js/somescript.js"></script>
#      {% enddevonly %}
#
#
#  It can also be used to see if it's dev mode from another
#  plugin.
#

module Jekyll
  class DevOnlyTag < Liquid::Block
    def render(context)
      return super if Liquid::Tag.disabled?(context, 'devonly')

      if DevOnlyTag.dev?(context)
        super(context)
      end
    end

    def self.dev?(context)
      return true if ENV.key?('JEKYLL_TEST') && ENV['JEKYLL_TEST'] == '1'

      # Compatible with both Jekyll v1 and older config styles
      if context.registers[:site].config['server'] ||
         context.registers[:site].config['serving']
        return true
      end

      if context.registers[:site].config.key?('dev')
        return context.registers[:site].config['dev'] ? true : false
      end

      false
    end
  end
end

Liquid::Template.register_tag('devonly', Jekyll::DevOnlyTag)
