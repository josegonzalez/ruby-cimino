require 'rubygems'
require 'bundler'
require 'date'
require 'yaml'

# For tasks
require 'erb'
require 'tilt'
require 'clipboard'
require 'em-dir-watcher'
require 'net/http'
require 'uri'
require 'xmlrpc/client'

# Get rake configuration
c = YAML.load_file('source/_config.yml')

# Ensure all directories exist
[ 'source', '_tmp', '_tmp/pygments_code', '_tmp/stash' ].each do |dir|
  FileUtils.mkdir_p(File.expand_path('../' + dir, __FILE__))
end

task :default => :dev

#######################
# Working with Jekyll #
#######################

# TODO: Support SASS compiling through compass
desc 'Generate jekyll site'
task :generate do
  puts '## Move the stashed blog posts back to the posts directory'
  FileUtils.mv Dir.glob('_tmp/stash/*.*'), '_posts'

  puts '## Generating Site with Jekyll'
  Dir.chdir('source') { system 'jekyll' }
end

# TODO: Support SASS compiling through compass
desc 'Watch the site and regenerate when it changes'
task :watch do
  exclusions = ['_tmp', '_site', 'Gemfile']

  EM.run {
    dw = EMDirWatcher.watch '.', :exclude => exclusions do |paths|
      paths.each do |path|
        regenerate_site(relative)
      end
    end
    puts '>>> Watching for Changes <<<'
  }
end

# TODO: Continuously regenerate the blog when performing a preview
desc 'Preview the site in a web browser'
multitask :preview => [:start_serve] do
  system "open http://localhost:#{c["serve_port"]}"
end

desc 'start up an instance of serve on the output files'
task :start_serve => :stop_serve do
  cd c['site'] do
    print 'Starting serve...'
    ok_failed system("serve #{c['serve_port']} > /dev/null 2>&1 &")
  end
end

desc "stop all instances of serve"
task :stop_serve do
  cmd = "ps auxw | awk '/bin\\/serve\\ #{c["serve_port"]}/ { print $2 }'"
  pid = `#{cmd}`.strip
  if pid.empty?
    puts "Serve is not running"
  else
    print "Stoping serve..."
    ok_failed system("kill -9 #{pid}")
  end
end

# TODO: Support configuration of post extension
# TODO: Support initial categories and tags via a flag
# TODO: Figure out a better way to hack the exit process of Rakefiles
desc "Begin a new post in _posts"
task :new_post do
  unless ARGV.length > 1
    puts "USAGE: rake post 'the post title'"
    exit(1)
  end

  slug = "#{Date.today}-#{ARGV[1].downcase.gsub(/[^\w]+/, '-')}"
  file = File.join(File.dirname(__FILE__), 'source', '_posts', "#{slug}.#{c['format']}")

  # Ensure that the file does not exists or the user wishes to overwrite it
  if File.exists?(file)
    exit(1) if !ask("Post #{file} already exists. Overwrite?")
  end

  # Create the Template
  template_path = './_templates/post.erb'
  template_path = './source/_templates/post.erb' if File.exists?('./source/_templates/post.erb')
  template = Tilt.new(template_path)

  # Create the post file
  FileUtils.mkpath(File.dirname(file))
  File.open(file, 'w') {|f| f.write(template.render(Object.new, :title => ARGV[1], :c => c)) }

  # Post processing
  if c["editor"]
    puts "Opening file in editor using #{c['editor']}"
    system "#{c["editor"]} #{file}"
  else
    puts "Copying path to clipboard"
    Clipboard.copy file
  end

  exit(0)
end

# TODO: Implement :new_page
desc "Create a new page in /(filename)/index.markdown"
task :new_page do
    raise "### UNIMPLEMENTED"
end

# TODO: Add a flag to disable plugin compilation
# TODO: Error-checking when no post matches your filter
# TODO: Figure out a better way to hack the exit process of Rakefiles
desc "Generate a single, or set, of blog posts containing certain words in the filename"
task :isolate, :filename do |t, args|
  unless ARGV.length > 1
    puts "USAGE: rake isolate 'the-post-title'"
    exit(1)
  end

  puts '* Moving posts to stash dir'

  Dir.glob("_posts/*.*") do |post|
    FileUtils.mv post, "_tmp/stash" unless post.include?(ARGV[1])
  end

  puts '* Regenerating blog'
  Dir.chdir('source') { system "jekyll" }

  puts '* Moving posts from _tmp/stash/ directory to _posts/ directory'

  # Move the stashed blog posts back to the posts directory
  FileUtils.mv Dir.glob("_tmp/stash/*.*"), "_posts"

  exit(0) # Hack so that we don't have to worry about rake trying any funny business
end

desc "Move all stashed posts back into the posts directory, ready for site generation."
task :integrate do
  FileUtils.mv Dir.glob("_tmp/stash/*.*"), "_posts"
end

# TODO: Support SASS compiled files
desc "Clean out caches: _tmp"
task :clean do
  puts '* Removing Output'
  puts `rm -rf _tmp/* _site/*`
end

##############
# Deploying  #
##############

desc 'Generate and publish the entire site, and send out pings'
task :deploy => [:generate, :rsync, :sitemap, :ping] do
end

desc 'rsync the contents of ./_site to the server'
task :rsync do
  cmd = "rsync -avz '_site/' %s:%s" % [ c["ssh_user"], c["deploy_path"] ]
  puts '* Publishing files to live server'
  puts `#{cmd}`
end

desc 'Notify Google of the new sitemap'
task :sitemap do
  begin
    puts '* Pinging Google about our sitemap'
    Net::HTTP.get('www.google.com', '/webmasters/tools/ping?sitemap=' + URI.escape("%s/sitemap.xml" % [ c["url"] ]))
  rescue LoadError
    puts '! Could not ping Google about our sitemap, because Net::HTTP or URI could not be found.'
  end
end

desc 'Ping pingomatic'
task :ping do
  begin
    puts '* Pinging ping-o-matic'
    XMLRPC::Client.new('rpc.pingomatic.com', '/').call('weblogUpdates.extendedPing', 'Jose Diaz-Gonzalez' , c["url"], "%s/atom.xml" % [ c["url"] ])
  rescue LoadError
    puts '! Could not ping ping-o-matic, because XMLRPC::Client could not be found.'
  end
end

desc 'Run Jekyll in development mode'
task :dev do
  puts '* Running Jekyll with auto-generation and server'
  Dir.chdir('source') { system "jekyll --auto --server --lsi" }
end

desc 'Create and push a tag'
task :tag do
  t = ENV['T']
  m = ENV['M']
  unless t && m
    puts "USAGE: rake tag T='1.0-my-tag-name' M='My description of this tag'"
    exit(1)
  end

  puts '* Creating tag'
  puts `git tag -a -m "#{m}" #{t}`

  puts '* Pushing tags'
  puts `git push origin master --tags`
end

desc 'List all draft posts'
task :drafts do
  puts `find ./_posts -type f -exec grep -H 'published: false' {} \\;`
end

desc "list tasks"
task :list do
  puts "Tasks: #{Rake::Task.tasks.to_sentence}"
  puts "(type rake -T for more detail)\n\n"
end

##############
# Deploying  #
##############

def regenerate_site(relative)
  puts "\n\n>>> Change Detected to: #{relative} <<<"
  IO.popen('rake generate'){|io| print(io.readpartial(512)) until io.eof?}
  puts '>>> Update Complete <<<'
end

def ok_failed(condition)
  puts condition ? "OK" : "FAILED"
end

def ask(message)
  print "#{message}\n[Y/n] "
  STDIN.gets.strip.downcase[0] == 'y'
end

class Array
  # Converts the array to a comma-separated sentence where the last element is joined by the connector word. Options:
  # * <tt>:words_connector</tt> - The sign or word used to join the elements in arrays with two or more elements (default: ", ")
  # * <tt>:two_words_connector</tt> - The sign or word used to join the elements in arrays with two elements (default: " and ")
  # * <tt>:last_word_connector</tt> - The sign or word used to join the last element in arrays with three or more elements (default: ", and ")
  def to_sentence(options = {})
    default_words_connector     = ", "
    default_two_words_connector = " and "
    default_last_word_connector = ", and "

    options.assert_valid_keys(:words_connector, :two_words_connector, :last_word_connector, :locale)
    options.reverse_merge! :words_connector => default_words_connector, :two_words_connector => default_two_words_connector, :last_word_connector => default_last_word_connector

    case length
      when 0
        ""
      when 1
        self[0].to_s
      when 2
        "#{self[0]}#{options[:two_words_connector]}#{self[1]}"
      else
        "#{self[0...-1].join(options[:words_connector])}#{options[:last_word_connector]}#{self[-1]}"
    end
  end
end

class Hash
  # Validate all keys in a hash match *valid keys, raising ArgumentError on a mismatch.
  # Note that keys are NOT treated indifferently, meaning if you use strings for keys but assert symbols
  # as keys, this will fail.
  #
  # ==== Examples
  #   { :name => "Rob", :years => "28" }.assert_valid_keys(:name, :age) # => raises "ArgumentError: Unknown key(s): years"
  #   { :name => "Rob", :age => "28" }.assert_valid_keys("name", "age") # => raises "ArgumentError: Unknown key(s): name, age"
  #   { :name => "Rob", :age => "28" }.assert_valid_keys(:name, :age) # => passes, raises nothing
  def assert_valid_keys(*valid_keys)
    unknown_keys = keys - [valid_keys].flatten
    raise(ArgumentError, "Unknown key(s): #{unknown_keys.join(", ")}") unless unknown_keys.empty?
  end
  # Allows for reverse merging two hashes where the keys in the calling hash take precedence over those
  # in the <tt>other_hash</tt>. This is particularly useful for initializing an option hash with default values:
  #
  #   def setup(options = {})
  #     options.reverse_merge! :size => 25, :velocity => 10
  #   end
  #
  # Using <tt>merge</tt>, the above example would look as follows:
  #
  #   def setup(options = {})
  #     { :size => 25, :velocity => 10 }.merge(options)
  #   end
  #
  # The default <tt>:size</tt> and <tt>:velocity</tt> are only set if the +options+ hash passed in doesn't already
  # have the respective key.
  def reverse_merge(other_hash)
    other_hash.merge(self)
  end
  # Performs the opposite of <tt>merge</tt>, with the keys and values from the first hash taking precedence over the second.
  # Modifies the receiver in place.
  def reverse_merge!(other_hash)
    merge!( other_hash ){|k,o,n| o }
  end
end

class String
  alias_method :starts_with?, :start_with?
  alias_method :ends_with?, :end_with?
end
