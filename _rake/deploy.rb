require 'net/http'
require 'xmlrpc/client'
require 'uri'

##############
# Deploying  #
##############

desc 'Generate and publish the entire site, and send out pings'
task :deploy => [:generate, :rsync, :sitemap, :ping] do
end

desc 'rsync the contents of ./_site to the server'
task :rsync do
  require_config

  cmd = "rsync -avz '_site/' %s:%s" % [ CONFIG["ssh_user"], CONFIG["deploy_path"] ]
  puts '* Publishing files to live server'
  puts `#{cmd}`
end

desc 'Notify Google of the new sitemap'
task :sitemap do
  require_config

  begin
    puts '* Pinging Google about our sitemap'
    Net::HTTP.get('www.google.com', '/webmasters/tools/ping?sitemap=' + URI.escape("%s/sitemap.xml" % [ CONFIG["url"] ]))
  rescue LoadError
    puts '! Could not ping Google about our sitemap, because Net::HTTP or URI could not be found.'
  end
end

desc 'Ping pingomatic'
task :ping do
  require_config

  begin
    puts '* Pinging ping-o-matic'
    XMLRPC::Client.new('rpc.pingomatic.com', '/').call('weblogUpdates.extendedPing', 'Jose Diaz-Gonzalez' , CONFIG["url"], "%s/atom.xml" % [ CONFIG["url"] ])
  rescue LoadError
    puts '! Could not ping ping-o-matic, because XMLRPC::Client could not be found.'
  end
end

desc 'Run Jekyll in development mode'
task :dev do
  require_config

  puts '* Running Jekyll with auto-generation and server'
  Dir.chdir(SOURCE_DIR) { system "jekyll --auto --server --lsi" }
end

desc 'Create and push a tag'
task :tag do
  require_config

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
  require_config

  puts `find ./#{SOURCE_DIR}/_posts -type f -exec grep -H 'published: false' {} \\;`
end
