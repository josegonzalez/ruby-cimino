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
desc 'Test generation of jekyll site'
task :test do
  puts '## Move the stashed blog posts back to the posts directory'
  FileUtils.mv Dir.glob('_tmp/stash/*.*'), '_posts'

  env_vars = {}
  [ 'theme' ].each { |k| env_vars[k] = ENV[k] if ENV.key?(k) }
  env_vars.map{ |k,v| ENV["JEKYLL_#{k.upcase}"] = v }

  puts '## Generating Site with Jekyll'
  Dir.chdir('source') { system "jekyll --no-lsi --url #{c['test_url']}" }
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

# TODO: Figure out a better way to hack the exit process of Rakefiles
desc "Begin a new post in _posts"
task :new_post do
  unless ARGV.length > 1
    puts "USAGE: rake new_post 'the post title'"
    exit(1)
  end

  data = { 'title' => ARGV[1] }
  [ 'category', 'comments', 'sharing'].each { |k| data[k] = c[k] if ENV.key?(k) }
  [ 'category', 'comments', 'sharing'].each { |k| data[k] = ENV[k] if ENV.key?(k) }
  [ 'category', 'comments', 'sharing'].each { |k| data[k] = true if !data.key?(k) }

  slug = "#{Date.today}-#{ARGV[1].downcase.gsub(/[^\w]+/, '-')}"
  file = File.join(File.dirname(__FILE__), 'source', '_posts', "#{slug}.#{c['format']}")

  created = create_file(c, file, 'post', data)
  exit(created ? 0 : 1)
end

desc "Create a new page in (filename)/index.#{c['format']}"
task :new_page do
  unless ARGV.length > 1
    puts "USAGE: rake new_page 'the post title'"
    exit(1)
  end

  data = { 'title' => ARGV[1] }
  [ 'comments', 'sharing'].each { |k| data[k] = c[k] if ENV.key?(k) }
  [ 'comments', 'sharing'].each { |k| data[k] = ENV[k] if ENV.key?(k) }
  [ 'comments', 'sharing'].each { |k| data[k] = true if !data.key?(k) }

  slug = "#{ARGV[1].downcase.gsub(/[^\w]+/, '-')}"
  file = File.join(File.dirname(__FILE__), 'source', slug, "index.#{c['format']}")

  created = create_file(c, file, 'page', data)
  exit(created ? 0 : 1)
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
  puts `find ./source/_posts -type f -exec grep -H 'published: false' {} \\;`
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

def create_file(c, file, template, data)
  if File.exists?(file) && !ask("#{file} already exists. Overwrite?")
    puts "Aborting creation of #{file}"
    return false
  end

  # Create the Template
  template_path = "./source/_templates/#{template}.erb"
  template_path = "./_templates/#{template}.erb" if !File.exists?(template_path)
  if !File.exists?(template_path)
    puts "Template '#{template}' does not exist!"
    return false
  end

  template = Tilt.new(template_path)

  # Create the post file
  FileUtils.mkpath(File.dirname(file))
  File.open(file, 'w') {|f| f.write(template.render(Object.new, :data => data)) }

  # Post processing
  if c["editor"]
    puts "Opening file in editor using #{c['editor']}"
    system "#{c["editor"]} #{file}"
  else
    puts "Copying path to clipboard"
    Clipboard.copy file
  end

  return true
end
