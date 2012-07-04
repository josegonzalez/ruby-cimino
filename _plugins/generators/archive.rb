# Title: ArchiveGenerator
# Original: https://github.com/rfelix/my_jekyll_extensions/blob/master/archive_gen/archive_gen.rb
# Description: Creates archive pages

module Jekyll

  class ArchiveIndex < Page
    def initialize(site, base, dir, type)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      # Use the already cached layout content and data for theme support
      self.content = @site.layouts[type].content
      self.data = @site.layouts[type].data

      self.data['collated_posts'] = self.collate(site)

      year, month, day = dir.split('/')
      self.data['year'] = year.to_i
      self.data['month'] = month.to_i if month
      self.data['day'] = day.to_i if day

      self.process(@name)
    end

    def collate(site)
      collated_posts = {}
      site.posts.reverse.each do |post|
        y, m, d = post.date.year, post.date.month, post.date.day

        collated_posts[ y ] = {} unless collated_posts.key? y
        collated_posts[ y ][ m ] = {} unless collated_posts[y].key? m
        collated_posts[ y ][ m ][ d ] = [] unless collated_posts[ y ][ m ].key? d
        collated_posts[ y ][ m ][ d ].push(post) unless collated_posts[ y ][ m ][ d ].include?(post)
      end
      collated_posts
    end

  end

  class ArchiveGenerator < Generator

    attr_accessor :collated_posts

    safe true

    def generate(site)
      return if !@enabled

      self.collated_posts = {}
      collate(site)

      self.collated_posts.keys.each do |y|
        write_index(site, y.to_s, 'archives/yearly') if site.layouts.key? 'archives/yearly'
        self.collated_posts[ y ].keys.each do |m|
          write_index(site, "%04d/%02d" % [ y.to_s, m.to_s ], 'archives/monthly') if site.layouts.key? 'archives/monthly'
          self.collated_posts[ y ][ m ].keys.each do |d|
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

    def collate(site)
      site.posts.reverse.each do |post|
        y, m, d = post.date.year, post.date.month, post.date.day

        self.collated_posts[ y ] = {} unless self.collated_posts.key? y
        self.collated_posts[ y ][ m ] = {} unless self.collated_posts[y].key? m
        self.collated_posts[ y ][ m ][ d ] = [] unless self.collated_posts[ y ][ m ].key? d
        self.collated_posts[ y ][ m ][ d ].push(post) unless self.collated_posts[ y ][ m ][ d ].include?(post)
      end
    end
  end

end
