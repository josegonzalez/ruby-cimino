# Title: SearchIndexGenerator
# Description: Creates a search.json search index

require 'pathname'

module Jekyll

  class SearchIndex < Page
    def initialize(site, base, dir, type)
      @site = site
      @base = base
      @dir  = dir
      @name = 'search.json'

      # Use the already cached layout content and data for theme support
      self.content = @site.layouts[type].content
      self.data = @site.layouts[type].data

      self.process(@name)
    end
  end

  class SearchGenerator < Generator
    safe true
    priority :low

    def generate(site)
      return if !@enabled

      site_folder = site.config['destination']
      Pathname.new(site_folder).mkdir unless File.directory?(site_folder)

      write_index(site, '/', 'search/search') if site.layouts.key? 'search/search'
    end

    def write_index(site, dir, type)
      atom = SearchIndex.new(site, site.source, dir, type)
      atom.render(site.layouts, site.site_payload)
      atom.write(site.dest)
      site.static_files << atom
    end
  end

end