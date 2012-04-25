# Title: PostTypeGenerator
# Description: Create custom post type pages, such as galleries or a portfolio

require 'fileutils'
require 'find'
require 'inflection'
require 'stringex'

module Jekyll

  class PostTypeIndex < Page
    def initialize(site, base, dir, type, post_path, config)
      slug = post_path.chomp(File.extname(post_path)).to_url
      @site = site
      @base = base
      @dir = File.join(dir, slug)

      # Use the already cached layout content and data for theme support
      self.content = @site.layouts[type].content
      self.data = @site.layouts[type].data

      # Read in the data from the post
      self.read_yaml(File.join(@base, config['folder']), post_path)

      self.data['slug'] = slug
      self.data['is_' + config['post_type']] = true

      if self.data.key?('date')
        # ensure Time via to_s and reparse
        self.date = Time.parse(self.data["date"].to_s)
      end

      if !self.data.key?('layout')
        self.data['layout'] = type
      end

      # Ignore the post_type page unless it has been marked as published.
      if self.data.key?('published') && self.data['published'] == false
        return false
      else
        self.data['published'] = true
      end

      ext = File.extname(post_path)
      unless ['.textile', '.markdown', '.html'].include?(ext)
        ext = '.textile'
      end

      @name = "index#{ext}"
      self.process(@name)
    end
  end

  class PostTypeList < Page
    def initialize(site,  base, dir, type, posts, config)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      # Use the already cached layout content and data for theme support
      self.content = @site.layouts[type].content
      self.data = @site.layouts[type].data

      self.data[::Inflection.plural(config['post_type'])] = posts
      self.data['is_' + config['post_type']] = true

      self.process(@name)
    end
  end

  # Jekyll hook - the generate method is called by jekyll, and generates all the post_type pages.
  class PostTypeGenerator < Generator
    safe true
    priority :low

    def initialize(config)
      super
      return @enabled = false if @plugin_config.empty?

      config = {}
      @plugin_config.each do |post_type|
        c = {}
        if post_type.is_a?(Hash)
          post_type, c['dir'] = post_type.shift
        elsif post_type.is_a?(Array)
          post_type, c = post_type
        end

        c ||= {}
        c = c.merge!({
          'page_title'  => post_type.capitalize + ': ',
          'folder'      => "_post_types/#{post_type}",
          'post_type'   => post_type,
          'dir'         => post_type,
        }){ |key, v1, v2| v1 }

        config[post_type] =  c
      end

      @plugin_config = config
    end

    def generate(site)
      return if !@enabled

      @plugin_config.each do |post_type, config|
        post_type_list = []

        type = "post_type/#{post_type}/index"
        if site.layouts.key?(type)
          posts = get_files(site, config["folder"])
          posts.each do |post_path|
            post = write_index(site, config['dir'], type, post_path, config)
            post_type_list << post unless post.nil?
          end
        end

        type = "post_type/#{post_type}/list"
        if post_type_list.size > 1 and site.layouts.key? type
          write_list(site, config['dir'], type, post_type_list, config)
        end
      end
    end

    def write_index(site, dir, type, post_path, config)
      index = PostTypeIndex.new(site, site.source, dir, type, post_path, config)
      return nil if not index.data['published']

      index.render(site.layouts, site.site_payload)
      index.write(site.dest)
      site.static_files << index
      index
    end

    def write_list(site, dir, type, posts, config)
      index = PostTypeList.new(site, site.source, dir, type, posts, config)
      index.render(site.layouts, site.site_payload)
      index.write(site.dest)
      site.static_files << index
    end

    # Gets a list of files in the _posttype folder with a .markdown or .textile extension.
    #
    # Return Array list of post config files.
    def get_files(site, folder)
      files = []
      Dir.chdir(File.join(site.source, folder)) { files = filter_entries(Dir.glob('**/*.*')) }
      files
    end

    def filter_entries(entries)
      entries = entries.reject do |e|
        unless ['.htaccess'].include?(e)
          ['.', '_', '#'].include?(e[0..0]) ||
          e[-1..-1] == '~' ||
          File.symlink?(e)
        end
      end
    end
  end

end
