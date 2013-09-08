# Title: highlight_code
# Original: https://github.com/imathis/octopress/blob/master/plugins/pygments_code.rb
# Description: Remove need for built-in Pygments syntax highlighting in favor of ruby gem implementations of syntax highlighting

# Figure out

highlighter = 'pygments'
config = YAML.load_file(File.join(File.dirname(__FILE__), '..', '..', 'source', '_config.yml'))
if config.key?("highlighter")
  highlighter = config['highlighter']
end

highlighter = 'pygments' if ![ 'coderay', 'pygments', 'ultraviolet', 'rouge' ].member?(highlighter)
highlighter = 'uv' if highlighter == 'ultraviolet'

require highlighter
require 'fileutils'
require 'digest/md5'

HIGHLIGHTER_IN_USE = highlighter
CODE_CACHE_DIR = File.dirname(__FILE__) + "/../../_tmp/#{highlighter}_code"
FileUtils.mkdir_p(CODE_CACHE_DIR)
File.chmod(0777, CODE_CACHE_DIR)

module HighlightCode

  def highlight(code, lang)
    lang = 'objc' if lang == 'm'
    lang = 'ruby' if lang == 'ru'
    lang = 'ruby' if lang == 'rb'
    lang = 'perl' if lang == 'pl'
    lang = 'yaml' if lang == 'yml'
    lang = 'js' if ['javascript', 'js', 'json'].member?(lang)

    return _highlight(code, lang)

    if defined?(CODE_CACHE_DIR)
      path = File.join(CODE_CACHE_DIR, "#{lang}-#{Digest::MD5.hexdigest(code)}.html")
      if File.exist?(path)
        highlighted_code = File.read(path)
      else
        highlighted_code = _highlight(code, lang)
        File.open(path, 'w') {|f| f.print(highlighted_code) }
      end
    else
      highlighted_code = _highlight(code, lang)
    end

    highlighted_code
  end

  def _highlight(code, lang)
    if HIGHLIGHTER_IN_USE == 'pygments'
      highlighted_code = pygments(code, lang)
    elsif HIGHLIGHTER_IN_USE == 'coderay'
      coderay_lang = lang
      coderay_lang = 'text' if coderay_lang == 'bash'
      highlighted_code = coderay(code, coderay_lang)
    elsif HIGHLIGHTER_IN_USE == 'uv'
      highlighted_code = ultraviolet(code, lang)
    elsif HIGHLIGHTER_IN_USE == 'rouge'
      highlighted_code = rouge(code, lang)
    end

    # strip out divs <div class="highlight">
    # highlighted_code = highlighted_code.match(/<pre>(.+)<\/pre>/m)[1].to_s.gsub(/ *$/, '')
    tableize_code(highlighted_code, lang)
  end

  def ultraviolet(code, lang)
    Uv.parse(code, 'html', lang, false, 'dawn')
  end

  def coderay(code, lang)
    CodeRay.scan(code, lang).div(:css => :class)
  end

  def pygments(code, lang)
    Pygments.highlight(code, :lexer => lang, :formatter => 'html')
  end

  def rouge(code, lang)
    formatter = Rouge::Formatters::HTML.new({:wrap => false})
    lexer = Rouge::Lexers::Javascript.new if lang == 'js'
    lexer = Rouge::Lexers::PHP.new if lang == 'php'
    lexer = Rouge::Lexers::Python.new if lang == 'python'
    lexer = Rouge::Lexers::SQL.new if lang == 'sql'
    lexer = Rouge::Lexers::PHP.new if lang == 'php'
    formatter.format(lexer.lex(code))
  end

  def tableize_code(str, lang = '')
    table = '<div class="highlight"><table cellpadding=0 cellspacing=0><tr><td class="gutter"><pre class="line-numbers"><code>'
    code = ''
    pos = 1
    str.lines.each_with_index do |line, index|
      next if index == 0 && line == "\n"
      table += "<span class='line-number line-#{pos}'>#{pos}</span>\n"
      code  += "<span class='line line-#{pos}'>#{line}</span>"
      pos = index + 1
    end
    table += "</code></pre></td><td class='code'><pre><code class='#{lang}'>#{code}</code></pre></td></tr></table></div>"

    safe_wrap(table)
  end

  # Wrap input with a <div>
  def safe_wrap(input)
    "<div class='bogus-wrapper'><notextile>#{input}</notextile></div>"
  end

  # This must be applied after the
  def unwrap(input)
    input.gsub(/<div class='bogus-wrapper'><notextile>(.+?)<\/notextile><\/div>/m) do
      $1
    end
  end

end
