# Title: highlight_code
# Original: https://github.com/imathis/octopress/blob/master/plugins/pygments_code.rb
# Description: Remove need for built-in Pygments syntax highlighting in favor of ruby gem implementations of syntax highlighting

# Figure out

highlighter = 'pygments'
config = YAML.load_file(File.join(File.dirname(__FILE__), '..', '..', 'source', '_config.yml'))
if config.key?("highlighter")
  highlighter = config['highlighter']
end

highlighter = 'pygments' if ![ 'coderay', 'pygments', 'ultraviolet' ].member?(highlighter)
highlighter = 'uv' if highlighter == 'ultraviolet'

require highlighter
require 'fileutils'
require 'digest/md5'

HIGHLIGHTER_IN_USE = highlighter
CODE_CACHE_DIR = File.dirname(__FILE__) + "/../../_tmp/#{highlighter}_code"
FileUtils.mkdir_p(CODE_CACHE_DIR)

module HighlightCode

  def highlight(str, lang)
    lang = 'objc' if lang == 'm'
    lang = 'ruby' if lang == 'ru'
    lang = 'ruby' if lang == 'rb'
    lang = 'perl' if lang == 'pl'
    lang = 'yaml' if lang == 'yml'

    if HIGHLIGHTER_IN_USE == 'pygments'
      str = pygments(str, lang)
    elsif HIGHLIGHTER_IN_USE == 'coderay'
      coderay_lang = lang
      coderay_lang = 'text' if coderay_lang == 'bash'
      str = coderay(str, coderay_lang)
    elsif HIGHLIGHTER_IN_USE == 'uv'
      str = ultraviolet(str, lang)
    end

    str = str.match(/<pre>(.+)<\/pre>/m)[1].to_s.gsub(/ *$/, '') #strip out divs <div class="highlight">
    tableize_code(str, lang)
  end

  def ultraviolet(code, lang)
    if defined?(CODE_CACHE_DIR)
      path = File.join(CODE_CACHE_DIR, "#{lang}-#{Digest::MD5.hexdigest(code)}.html")
      if File.exist?(path)
        highlighted_code = File.read(path)
      else
        highlighted_code = Uv.parse(code, 'html', lang, false, 'dawn')
        File.open(path, 'w') {|f| f.print(highlighted_code) }
      end
    else
      highlighted_code = Uv.parse(code, 'html', lang, false, 'dawn')
    end
    highlighted_code
  end

  def coderay(code, lang)
    if defined?(CODE_CACHE_DIR)
      path = File.join(CODE_CACHE_DIR, "#{lang}-#{Digest::MD5.hexdigest(code)}.html")
      if File.exist?(path)
        highlighted_code = File.read(path)
      else
        highlighted_code = CodeRay.scan(code, lang).div(:css => :class)
        File.open(path, 'w') {|f| f.print(highlighted_code) }
      end
    else
      highlighted_code = CodeRay.scan(code, lang).div(:css => :class)
    end
    highlighted_code
  end

  def pygments(code, lang)
    if defined?(CODE_CACHE_DIR)
      path = File.join(CODE_CACHE_DIR, "#{lang}-#{Digest::MD5.hexdigest(code)}.html")
      if File.exist?(path)
        highlighted_code = File.read(path)
      else
        highlighted_code = Pygments.highlight(code, :lexer => lang, :formatter => 'html')
        File.open(path, 'w') {|f| f.print(highlighted_code) }
      end
    else
      highlighted_code = Pygments.highlight(code, :lexer => lang, :formatter => 'html')
    end
    highlighted_code
  end

  def tableize_code (str, lang = '')
    table = '<div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers">'
    code = ''
    str.lines.each_with_index do |line,index|
      table += "<span class='line-number line-#{index+1}'>#{index+1}</span>\n"
      code  += "<span class='line line-#{index+1}'>#{line}</span>"
    end
    table += "</pre></td><td class='code'><pre><code class='#{lang}'>#{code}</code></pre></td></tr></table></div>"
  end

end
