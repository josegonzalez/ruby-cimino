require "rubygems"
require "bundler"
require "date"
require "yaml"

# For tasks
require "clipboard"
require 'em-dir-watcher'
require 'net/http'
require 'uri'
require 'xmlrpc/client'

# Get rake configuration
config = YAML.load_file("source/_config.yml")

# Ensure all directories exist
[ "source", "_tmp", "_tmp/pygments_code", "_tmp/stash" ].each do |dir|
  FileUtils.mkdir_p(File.expand_path('../' + dir, __FILE__))
end

task :default => :dev

#######################
# Working with Jekyll #
#######################

# TODO: Support SASS compiling through compass
desc "Generate jekyll site"
task :generate do
  puts "## Move the stashed blog posts back to the posts directory"
  FileUtils.mv Dir.glob("_tmp/stash/*.*"), "_posts"

  puts "## Generating Site with Jekyll"
  Dir.chdir('source') { system "jekyll" }
end

# TODO: Support SASS compiling through compass
desc "Watch the site and regenerate when it changes"
task :watch do
  exclusions = ['_tmp', '_site', 'Gemfile']

  EM.run {
    dw = EMDirWatcher.watch '.', :exclude => exclusions do |paths|
      paths.each do |path|
        regenerate_site(relative)
      end
    end
    puts ">>> Watching for Changes <<<"
  }
end

# TODO: Continuously regenerate the blog when performing a preview
desc "Preview the site in a web browser"
multitask :preview => [:start_serve] do
  system "open http://localhost:%s" %  [ config["serve_port"] ]
end

desc "start up an instance of serve on the output files"
task :start_serve => :stop_serve do
  cd config["site"] do
    print "Starting serve..."
    ok_failed system("serve % > /dev/null 2>&1 &" [ config["serve_port"] ])
  end
end

desc "stop all instances of serve"
task :stop_serve do
  cmd = "ps auxw | awk '/bin\\/serve\\ %s/ { print $2 }'" % [ config["serve_port"] ]
  pid = `#{cmd}`.strip
  if pid.empty?
    puts "Serve is not running"
  else
    print "Stoping serve..."
    ok_failed system("kill -9 #{pid}")
  end
end

# TODO: Support configuration of post extension
# TODO: Support error checking if the post already exists
# TODO: Support a custom template for the initial post
# TODO: Support initial categories and tags via a flag
# TODO: Figure out a better way to hack the exit process of Rakefiles
desc "Begin a new post in _posts"
task :new_post do
  unless ARGV.length > 1
    puts "USAGE: rake post 'the post title'"
    exit(1)
  end

  slug = "#{Date.today}-#{ARGV[1].downcase.gsub(/[^\w]+/, '-')}"
  file = File.join(File.dirname(__FILE__), config['source'], '_posts', slug + '.markdown')
  create_blank_post(file, ARGV[1])

  if config["editor"]
    system "#{config["editor"]} #{file}"
    puts "Opening file in editor using %s" % [ config["editor"] ]
  else
    Clipboard.copy file
    puts "Copied path to clipboard"
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
  cmd = "rsync -avz '_site/' %s:%s" % [ config["ssh_user"], config["deploy_path"] ]
  puts '* Publishing files to live server'
  puts `#{cmd}`
end

desc 'Notify Google of the new sitemap'
task :sitemap do
  begin
    puts '* Pinging Google about our sitemap'
    Net::HTTP.get('www.google.com', '/webmasters/tools/ping?sitemap=' + URI.escape("%s/sitemap.xml" % [ config["url"] ]))
  rescue LoadError
    puts '! Could not ping Google about our sitemap, because Net::HTTP or URI could not be found.'
  end
end

desc 'Ping pingomatic'
task :ping do
  begin
    puts '* Pinging ping-o-matic'
    XMLRPC::Client.new('rpc.pingomatic.com', '/').call('weblogUpdates.extendedPing', 'Jose Diaz-Gonzalez' , config["url"], "%s/atom.xml" % [ config["url"] ])
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

# Helper method for :draft and :post, that required a TITLE environment
# variable to be set. If there is none, the task will exit.
#
# If there is a title given, then this method will return it and a escaped
# version suitable for filenames.

# Helper method for :draft and :post, that will create a file at a given
# location and fill it with an empty post.
def create_blank_post(path, title)
  # Create the directories to this path if needed
  FileUtils.mkpath(File.dirname(path))

  # Write the template to the file
  File.open(path, "w") do |f|
    f << <<-EOS.gsub(/^    /, '')
    ---
      title: #{title}
      category: Code
      tags:
      layout: post
    ---

    EOS
  end
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
