# Title: Jekyll::Plugin Config
# Description: Extends the Jekyll::Plugin class to add plugin-related configuration to our global _config.yml

require 'inflection'

module Jekyll

  class Plugin

    # Initialize a new plugin.
    #
    # - Ensures that the plugin has it's proper config
    # - Enables/disables a plugin as necessary
    #
    # config - The Hash of configuration options.
    #
    # Returns a new instance.
    # Initialize the converter.
    #
    # Returns an initialized Converter.
    def initialize(config = {})
      super

      @config = config

      klass = underscore(self.class).gsub('jekyll/', '')
      ['_generator', '_converter'].each {|n| klass = klass.gsub(n, '')}

      parent_klass = self.is_a?(Generator) ? 'generators' : 'converters'

      if config.key?(parent_klass) && config[parent_klass].key?(klass)
        @plugin_config = config[parent_klass][klass]
      end

      @plugin_config ||= {}

      @enabled = true
      return if !config.key?("disabled_#{parent_klass}")

      disabled = config["disabled_#{parent_klass}"]
      disabled = [disabled] if disabled.is_a?('String')
      @enabled = false if disabled.member?(klass)
    end
  end

  class Converter < Plugin
    alias_method :original_initialize, :initialize
    # Initialize the converter.
    #
    # Returns an initialized Converter.
    def initialize(config = {})
      super
      original_initialize(config)
    end
  end

end

module Liquid

  class Tag
    alias_method :original_render, :render

    def render(context)
      super
      config = context.registers[:site].config

      klass = underscore(self.class).gsub('jekyll/', '')
      ['_tag'].each {|n| klass = klass.gsub(n, '')}

      if config.key?('tags') && config['tags'].key?(klass)
        @plugin_config = config['tags'][klass]
      end

      @plugin_config ||= {}

      @enabled = true
      if config.key?("disabled_tags")
        disabled = config["disabled_tags"]
        disabled = [disabled] if disabled.is_a?('String')
        @enabled = false if disabled.member?(klass)
      end

      original_render(context)
    end
  end

  class Block < Tag
    alias_method :original_render, :render

    def render(context)
      config = context.registers[:site].config

      klass = underscore(self.class).gsub('jekyll/', '')
      ['_tag'].each {|n| klass = klass.gsub(n, '')}
      if config.key?('tags') && config['tags'].key?(klass)
        @plugin_config = config['tags'][klass]
      end

      @plugin_config ||= {}

      @enabled = true
      if config.key?("disabled_tags")
        disabled = config["disabled_tags"]
        disabled = [disabled] if disabled.is_a?('String')
        @enabled = false if disabled.member?(klass)
      end

      original_render(context)
    end
  end

end

def underscore(camel_cased_word)
  word = camel_cased_word.to_s.dup
  word.gsub!(/::/, '/')
  word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
  word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
  word.tr!("-", "_")
  word.downcase!
  word
end
