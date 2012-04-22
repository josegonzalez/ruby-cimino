# Title: AtomGenerator
# Description: Creates an atom.xml feed

require 'pathname'

module Jekyll
  class AtomIndex < Page
    def initialize(site, base, dir, type)
      @site = site
      @base = base
      @dir  = dir
      @name = 'atom.xml'

      # Use the already cached layout content and data for theme support
      self.content = @site.layouts[type].content
      self.data = @site.layouts[type].data

      self.process(@name)
    end
  end

  class AtomGenerator < Generator
    safe true
    priority :low

    def generate(site)
      site_folder = site.config['destination']
      Pathname.new(site_folder).mkdir unless File.directory?(site_folder)

      write_index(site, '/', 'atom/atom') if site.layouts.key? 'atom/atom'
    end

    def write_index(site, dir, type)
      atom = AtomIndex.new(site, site.source, dir, type)
      atom.render(site.layouts, site.site_payload)
      atom.write(site.dest)
      site.static_files << atom
    end
  end
end