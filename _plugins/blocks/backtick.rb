# Title: BacktickTag
# Original: https://github.com/imathis/octopress/blob/master/plugins/backtick_code_block.rb
# Description: Allow placing codeblocks within three ```, github-style

require File.dirname(__FILE__) + '/../_extensions/post_filter'
require 'rubypants'

module Jekyll
  class BacktickCodeBlockFilter < PostFilter
    def initialize(config)
      @tag = "highlight"
      @tag = config['tags']['backtick'] if config.key?('tags') && config['tags'].key?('backtick')
      @enabled = true
      @enabled = false if config.key?('disabled_tags') && config['disabled_tags'].member?('backtick_code')
      super
    end

    def pre_render(post)
      return post.content unless @enabled
      post.content = post.content.gsub(/^`{3} (.*)$/, "{% #{@tag} \\1 %}")
      post.content = post.content.gsub(/^`{3}$/, "{% end#{@tag} %}")
    end

    def post_render(post)
      post.content
    end
  end
end
