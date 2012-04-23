# Title: BacktickTag
# Original: https://github.com/imathis/octopress/blob/master/plugins/backtick_code_block.rb
# Description: Allow placing codeblocks within three ```, github-style

require File.dirname(__FILE__) + '/../extensions/post_filter'
require 'rubypants'

module Jekyll
  class BacktickCodeBlockFilter < PostFilter
    def initialize(config)
      @tag = "highlight"
      if config.key?('backtick') and config['backtick'].key?('tag')
        @tag = config['backtick']['tag']
      end
      super
    end

    def pre_render(post)
      post.content = post.content.gsub(/^`{3} (.*)$/, "{% #{@tag} \\1 %}")
      post.content = post.content.gsub(/^`{3}$/, "{% end#{@tag} %}")
    end

    def post_render(post)
      post.content
    end
  end
end