# Title: GenericIndexGenerator
# Original: https://github.com/rfelix/my_jekyll_extensions/blob/master/tag_gen/tag_gen.rb
# Description: Creates generic index pages

require 'inflection'

module Jekyll

  class GenericIndexPage < Page
    def initialize(site, base, dir, type, page, config)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      # Use the already cached layout content and data for theme support
      self.content = @site.layouts[type].content
      self.data = @site.layouts[type].data

      self.data['title'] = "#{config["title_prefix"]}#{page}"
      self.data[config['page_type']] = page
      related(page, config) if config['related']

      self.process(@name)
    end

    def related(page, config)
      self.data['related'] = []

      site_coll = @site.send ::Inflection.plural(config['page_type'])
      site_coll[page].each do |post|
        post_coll = post.send ::Inflection.plural(config['page_type'])
        post_coll.each do |rel|
          self.data['related'].push(rel)
        end
      end

      self.data['related'] = self.data['related'].uniq
    end
  end

  class GenericIndexList < Page
    attr_accessor :page_type

    def initialize(site,  base, dir, type, pages, config)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      # Use the already cached layout content and data for theme support
      self.content = @site.layouts[type].content
      self.data = @site.layouts[type].data

      self.data[::Inflection.plural(config['page_type'])] = pages

      self.process(@name)
    end
  end

  class GenericPageGenerator < Generator
    safe true

    def generate(site)
      return if !site.config.has_key?('generic_index') || site.config['generic_index'].nil?

      site.config['generic_index'].each do |page_type|
        config = {}
        if page_type.is_a?(Hash)
          page_type, config['related'] = page_type.shift
        elsif page_type.is_a?(Array)
          page_type, config = page_type
        end

        config = config.merge!({
          'related'    => false,
          'page_title' => page_type.capitalize + ': ',
          'dir'        => ::Inflection.plural(page_type),
          'page_type'  => page_type,
        }){ |key, v1, v2| v1 }

        page_types = site.send ::Inflection.plural(page_type)
        next unless page_types

        type = "generic_index/#{page_type}/index"
        if site.layouts.key?(type)
          page_types.keys.each do |page|
            write_index(site, File.join(config['dir'], page.gsub(/\s/, "-").gsub(/[^\w-]/, '').downcase), type, page, config)
          end
        end

        type = "generic_index/#{page_type}/list"
        write_list(site, config['dir'], type, page_types.keys.sort, config) if site.layouts.key?(type)
      end
    end

    def write_index(site, dir, type, page, config)
      index = GenericIndexIndex.new(site, site.source, dir, type, page, config)
      index.render(site.layouts, site.site_payload)
      index.write(site.dest)
      site.static_files << index
    end

    def write_list(site, dir, type, pages, config)
      index = GenericIndexList.new(site, site.source, dir, type, pages, config)
      index.render(site.layouts, site.site_payload)
      index.write(site.dest)
      site.static_files << index
    end
  end

end
