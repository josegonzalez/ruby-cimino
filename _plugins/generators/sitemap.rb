# Title: SitemapGenerator
# Original: https://github.com/recurser/jekyll-plugins/blob/master/generate_sitemap.rb
# Description: Creates a sitemap.xml

require 'pathname'

module Jekyll
  class Page
    def subfolder
      @dir
    end
  end

  class SitemapIndex < Page
    def initialize(site, base, dir, type)
      @site = site
      @base = base
      @dir  = dir
      @name = 'sitemap.xml'

      # Use the already cached layout content and data for theme support
      self.content = @site.layouts[type].content
      self.data = @site.layouts[type].data

      self.data['pages'] = payload
      self.process(@name)
    end

    def payload
      pages = []

      @site.pages.each do |page|
        path     = page.subfolder + '/' + page.name
        next unless File.exists?(@site.source + path)
        mod_date = File.mtime(@site.source + path)

        # Remove the trailing 'index.html' if there is one, and just output the folder name.
        path = path[0..-11] if path=~/index.html$/
        # Force file endings to be .html
        path = path.gsub(/\.(markdown|textile)$/i, '.html')

        next if path == '/robots.txt'

        pages << { 'url' => path, 'date' => mod_date.strftime("%Y-%m-%d")} unless path =~/error/
      end

      @site.site_payload['site']['posts'].each do |post|
        pages << { 'url' => post.url, 'date' => post.date.strftime("%Y-%m-%d")}
      end

      pages
    end
  end

  class SitemapGenerator < Generator
    safe true
    priority :low

    def generate(site)
      site_folder = site.config['destination']
      Pathname.new(site_folder).mkdir unless File.directory?(site_folder)

      write_index(site, '/', 'sitemap/sitemap') if site.layouts.key? 'sitemap/sitemap'
    end

    def write_index(site, dir, type)
      sitemap = SitemapIndex.new(site, site.source, dir, type)
      sitemap.render(site.layouts, site.site_payload)
      sitemap.write(site.dest)
      site.static_files << sitemap
    end
  end
end
