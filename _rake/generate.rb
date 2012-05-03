# TODO: Support SASS compiled files
desc "Clean out caches: _tmp"
task :clean do
  require_config

  puts '* Removing Output'
  puts `rm -rf _tmp/* _site/*`
end

# TODO: Support SASS compiling through compass
desc 'Generate jekyll site'
task :generate do
  require_config

  puts '## Move the stashed blog posts back to the posts directory'
  FileUtils.mv Dir.glob('_tmp/stash/*.*'), '_posts'

  puts '## Generating Site with Jekyll'
  Dir.chdir(SOURCE_DIR) { system 'jekyll' }
end

desc "Move all stashed posts back into the posts directory, ready for site generation."
task :integrate do
  require_config

  FileUtils.mv Dir.glob("_tmp/stash/*.*"), "_posts"
end

# TODO: Add a flag to disable plugin compilation
# TODO: Error-checking when no post matches your filter
# TODO: Figure out a better way to hack the exit process of Rakefiles
desc "Generate a single, or set, of blog posts containing certain words in the filename"
task :isolate, :filename do |t, args|
  require_config

  unless ARGV.length > 1
    puts "USAGE: rake isolate 'the-post-title'"
    exit(1)
  end

  puts '* Moving posts to stash dir'

  Dir.glob("_posts/*.*") do |post|
    FileUtils.mv post, "_tmp/stash" unless post.include?(ARGV[1])
  end

  puts '* Regenerating blog'
  Dir.chdir(SOURCE_DIR) { system "jekyll" }

  puts '* Moving posts from _tmp/stash/ directory to _posts/ directory'

  # Move the stashed blog posts back to the posts directory
  FileUtils.mv Dir.glob("_tmp/stash/*.*"), "_posts"

  exit(0) # Hack so that we don't have to worry about rake trying any funny business
end

# TODO: Support SASS compiling through compass
desc 'Test generation of jekyll site'
task :test do
  require_config

  puts '## Move the stashed blog posts back to the posts directory'
  FileUtils.mv Dir.glob('_tmp/stash/*.*'), '_posts'

  env_vars = {}
  [ 'theme' ].each { |k| env_vars[k] = ENV[k] if ENV.key?(k) }
  env_vars.map{ |k,v| ENV["JEKYLL_#{k.upcase}"] = v }

  puts '## Generating Site with Jekyll'
  Dir.chdir(SOURCE_DIR) { system "jekyll --no-lsi --url #{CONFIG['test_url']}" }
end
