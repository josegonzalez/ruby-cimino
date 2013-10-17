# Title: DitaaBlock
# Source: https://github.com/matze/jekyll-ditaa
# Description: This plugin allows you to write ditaa markup within a ditaa block,
#              generate the image file and replace the markup with the image. If
#              the image could not be generated, the plugin falls back to a <pre>
#              block with the ditaa markup.
# Usage: Install ditaa:
#
#        apt-get install ditaa # ubuntu
#        brew install ditaa # mac
#
#        {% ditaa %}
#        /----+  DAAP /-----+-----+ Audio  /--------+
#        | PC |<------| RPi | MPD |------->| Stereo |
#        +----+       +-----+-----+        +--------+
#           |                 ^ ^
#           |     ncmpcpp     | | mpdroid /---------+
#           +--------=--------+ +----=----| Nexus S |
#                                         +---------+
#        {% endditaa %}
#
#        Ditaa options can be passed through the tag:
#        {% ditaa -S -E %}
#        +---------------------------+
#        | No separation and shadows |
#        +---------------------------+
#        {% endditaa %}

require 'fileutils'
require 'digest/md5'

DITAA_CACHE_DIR = File.dirname(__FILE__) + "/../../_tmp/ditaa"
FileUtils.mkdir_p(DITAA_CACHE_DIR)
File.chmod(0777, DITAA_CACHE_DIR)


module Jekyll
  class DitaaBlock < Liquid::Block
    def initialize(tag_name, options, tokens)
      super

      ditaa_exists = system('which ditaa > /dev/null 2>&1')

      # There is always a blank line at the beginning, so we remove to get rid
      # of that undesired top padding in the ditaa output
      ditaa = @nodelist.to_s
      ditaa.gsub!('\n', "\n")
      ditaa.gsub!(/^$\n/, "")
      ditaa.gsub!(/^\[\"\n/, "")
      ditaa.gsub!(/\"\]$/, "")
      ditaa.gsub!(/\\\\/, "\\")

      hash = Digest::MD5.hexdigest(@nodelist.to_s + options)
      ditaa_home = 'images/ditaa/'
      FileUtils.mkdir_p(ditaa_home)
      @png_name = ditaa_home + 'ditaa-' + hash + '.png'

      if ditaa_exists
        if not File.exists?(@png_name)
          args = ' ' + options + ' -o'
          tmp_file = "#{DITAA_CACHE_DIR}/ditaa-#{hash}.txt"
          File.open(tmp_file, 'w') {|f| f.write(ditaa)}
          @png_exists = system("ditaa #{tmp_file} " + @png_name + args)
        end
      end
      @png_exists = File.exists?(@png_name)
    end

    def render(context)
      return super if Liquid::Tag.disabled?(context, 'ditaa')

      if @png_exists
        '<figure class="ditaa-figure"><a href="/' + @png_name + '" title="' + @png_name + '" ><img src="/' + @png_name + '" title="' + @png_name + '" max-width="99%" /></a></figure>'
      else
        '<code><pre>' + super + '</pre></code>'
      end
    end
  end
end

Liquid::Template.register_tag('ditaa', Jekyll::DitaaBlock)
