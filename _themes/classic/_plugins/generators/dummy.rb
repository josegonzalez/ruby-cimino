# Title: DummyGenerator
# Description: A dummy generator

module Jekyll

  class DummyGenerator < Generator

    attr_accessor :collated_posts

    safe true

    def generate(site)
      return
    end

  end

end
