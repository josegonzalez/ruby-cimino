# Title: Pluralize
# Source: https://github.com/bdesham/pluralize
# Description: A Liquid filter to make it easy to form correct plurals.
# Usage: {{ remaining_time | pluralize: "minute" }}
#        {{ cul_de_sac_list.length | pluralize: "cul-de-sac", "culs-de-sac" }}

module Jekyll
  module Pluralize
    def pluralize(number, singular, plural=nil)
      if number == 1
        "#{number} #{singular}"
      elsif plural == nil
        "#{number} #{singular}s"
      else
        "#{number} #{plural}"
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::Pluralize)
