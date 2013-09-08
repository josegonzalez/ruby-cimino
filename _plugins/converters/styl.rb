# Title: StylConverter
# Source: https://gist.github.com/988201
# Description: A Jekyll plugin to convert .styl to .css
# Caveats:
#   1. Files intended for conversion must have empty YAML front matter a the top.
#   2. You can not @import .styl files intended to be converted.

require 'stylus'

module Jekyll
  class StylConverter < Converter
    safe true

    def setup
      return if @setup
      require 'stylus'
      Stylus.compress = @plugin_config['stylus']['compress'] if @plugin_config['stylus']['compress']
      Stylus.paths << @plugin_config['stylus']['path'] if @plugin_config['stylus']['path']
      @setup = true
    rescue LoadError
      STDERR.puts 'You are missing a library required for Stylus. Please run:'
      STDERR.puts '  $ [sudo] gem install stylus'
      raise FatalException.new('Missing dependency: stylus')
    end

    def matches(ext)
      @enabled ? ext=~ /styl/i : false
    end

    def output_ext(ext)
      '.css'
    end

    def convert(content)
      begin
        setup
        Stylus.compile content
      rescue => e
        puts "Stylus Exception: #{e.message}"
      end
    end
  end
end
