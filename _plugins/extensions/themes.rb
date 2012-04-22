# Title: Themes Jekyll Extension
# Description: Add theme support to Jekyll
#
# Usage:
#
#  - Set the `theme` config key to a string in your `_config.yml`
#  - Create a folder named after your theme in `_themes`
#  - Create `includes` and `layouts` directories
#  - Add your overriden includes/layouts in the respective folders
#
# Sample Layout:
#
#  .
#  |-- _includes
#  |   `-- sidebar.markdown
#  |-- _layouts
#  |   |-- default.html
#  |   `-- post.html
#  `-- _themes
#      `-- minimal
#          |-- _includes
#          |   `-- sidebar.markdown
#          `-- _layouts
#          |   `-- post.html

module Jekyll
  class Site
    alias_method :orig_read_directories, :read_directories

    # Read Site data from disk and load it into internal data structures.
    #
    # Returns nothing.
    def read
      self.read_layouts
      self.read_theme_directories
    end

    # Set layouts in the following order:
    #
    #  * ./_themes/classic/_layouts
    #  * ./source/_themes/THEME_NAME/_layouts
    #
    def read_layouts(dir = '')
      recursive_read_layouts(File.join('..', '_themes', 'classic', dir))
      recursive_read_layouts(File.join('_themes', self.config['theme'], dir)) if self.config.key?('theme')
    end

    # Read all the files recursively in <source>/<dir>/_layouts
    # and create a new Layout object with each one.
    #
    # Returns nothing.
    def recursive_read_layouts(dir = '')
      base = File.join(self.source, dir, "_layouts")
      return unless File.exists?(base)
      entries = []
      Dir.chdir(base) { entries = filter_entries(Dir.glob('**/*.*')) }

      entries.each do |f|
        name = f.split(".")[0..-2].join(".")
        self.layouts[name] = Layout.new(self, base, f)
      end
    end

    def read_theme_directories(dir = '')
      if self.config.key?('theme')
        theme = File.join('_themes', self.config['theme'])
        if File.exists?(File.join(self.source, theme))
          read_directories(File.join(theme, dir), theme)
        else
          read_directories(File.join('..', '_themes', 'classic', dir), theme)
        end
      end
      read_directories(dir)
    end

    def read_directories(dir = '', theme = false)
      base = File.join(self.source, dir)
      return if not File.exists?(base)

      entries = Dir.chdir(base) { filter_entries(Dir['*']) }

      self.read_posts(dir)

      entries.each do |f|
        f_abs = File.join(base, f)
        f_rel = File.join(dir, f)
        if File.directory?(f_abs)
          next if self.dest.sub(/\/$/, '') == f_abs
          read_directories(f_rel, theme)
        elsif !File.symlink?(f_abs)
          first3 = File.open(f_abs) { |fd| fd.read(3) }
          if first3 == "---"
            # file appears to have a YAML header so process it as a page
            pages << Page.new(self, self.source, dir, f, theme)
          else
            # otherwise treat it as a static file
            static_files << StaticFile.new(self, self.source, dir, f, theme)
          end
        end
      end
    end
  end

  class StaticFile
    attr_accessor :theme

    # Initialize a new StaticFile.
    #
    # site - The Site.
    # base - The String path to the <source>.
    # dir  - The String path between <source> and the file.
    # name - The String filename of the file.
    def initialize(site, base, dir, name, theme)
      @site = site
      @base = base
      @dir  = dir
      @name = name
      @theme = theme
    end

    def destination(dest)
      # The dir must be corrected when using themes
      dir = @theme ? @dir.split(@theme).last[1..-1] : @dir
      File.join(dest, dir, @name)
    end

  end

  class Page
    attr_accessor :theme

    # Initialize a new Page.
    #
    # site - The Site object.
    # base - The String path to the source.
    # dir  - The String path between the source and the file.
    # name - The String filename of the file.
    def initialize(site, base, dir, name, theme)
      @site = site
      @base = base
      @dir  = dir
      @name = name
      @theme = theme

      self.process(name)
      self.read_yaml(File.join(base, dir), name)
    end

    # Obtain destination path.
    #
    # dest - The String path to the destination dir.
    #
    # Returns the destination file path String.
    def destination(dest)
      # The dir must be corrected when using themes
      dir = @theme ? @dir.split(@theme).last[1..-1] : @dir

      # The url needs to be unescaped in order to preserve the correct
      # filename.
      path = File.join(dest, dir, CGI.unescape(self.url))
      path = File.join(path, "index.html") if self.url =~ /\/$/
      puts path
      path
    end

  end

  class ThemeIncludeTag < Liquid::Tag
    def initialize(tag_name, file, tokens)
      super
      @file = file.strip
    end

    # Try includes in the following order:
    #
    # * source/_themes/THEME_NAME/_includes
    # * _themes/classic/_includes
    #
    def render(context)
      if @file !~ /^[a-zA-Z0-9_\/\.-]+$/ || @file =~ /\.\// || @file =~ /\/\./
        return "Include file '#{@file}' contains invalid characters or sequences"
      end

      includes_dir = find_path(context)
      "Included file '#{@file}' not found in any _includes directories" if includes_dir.nil?

      Dir.chdir(includes_dir) do
        source = File.read(@file)
        partial = Liquid::Template.parse(source)
        context.stack do
          partial.render(context)
        end
      end
    end

    def find_path(context)
      site = context.registers[:site]

      dirs = [ File.join('..', '_themes', 'classic') ]
      dirs.unshift(File.join('_themes', site.config['theme'])) if site.config.key?('theme')

      dirs.each do |dir|
        includes_dir = File.join(site.source, dir, '_includes')

        next if File.symlink?(includes_dir)

        Dir.chdir(includes_dir) do
          choices = Dir['**/*'].reject { |x| File.symlink?(x) }
          return includes_dir if choices.include?(@file)
        end
      end

      nil
    end
  end

end

Liquid::Template.register_tag('include', Jekyll::ThemeIncludeTag)
