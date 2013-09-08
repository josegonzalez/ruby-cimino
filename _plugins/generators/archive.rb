# Title: ArchiveGenerator
# Original: https://github.com/rfelix/my_jekyll_extensions/blob/master/archive_gen/archive_gen.rb
# Description: Creates archive pages

require File.dirname(__FILE__) + '/../_extensions/post_collation'

module Jekyll
  class ArchiveIndex < Page
    include PostCollation

    def initialize(site, base, dir, type)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      # Use the already cached layout content and data for theme support
      self.content = @site.layouts[type].content
      self.data = @site.layouts[type].data

      self.data['collated_posts'] = self.collate(site.posts)

      year, month, day = dir.split('/')
      self.data['year'] = year.to_i
      self.data['month'] = month.to_i if month
      self.data['day'] = day.to_i if day

      self.process(@name)
    end

  end

  class ArchiveGenerator < Generator
    include PostCollation

    safe true

    def generate(site)
      return if !@enabled

      collated_posts = collate(site.posts)

      collated_posts.keys.each do |y|
        write_index(site, y.to_s, 'archives/yearly') if site.layouts.key? 'archives/yearly'
        collated_posts[ y ].keys.each do |m|
          write_index(site, "%04d/%02d" % [ y.to_s, m.to_s ], 'archives/monthly') if site.layouts.key? 'archives/monthly'
          collated_posts[ y ][ m ].keys.each do |d|
            write_index(site, "%04d/%02d/%02d" % [ y.to_s, m.to_s, d.to_s ], 'archives/daily') if site.layouts.key? 'archives/daily'
          end
        end
      end
    end

    def write_index(site, dir, type)
      archive = ArchiveIndex.new(site, site.source, dir, type)
      archive.render(site.layouts, site.site_payload)
      archive.write(site.dest)
      site.static_files << archive
    end
  end
end
