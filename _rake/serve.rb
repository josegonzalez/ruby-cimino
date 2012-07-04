require 'em-dir-watcher'

# TODO: Continuously regenerate the blog when performing a preview
desc 'Preview the site in a web browser'
multitask :preview => [:start_serve] do
  require_config

  system "open http://localhost:#{CONFIG["serve_port"]}"
end

desc 'start up an instance of serve on the output files'
task :start_serve => :stop_serve do
  require_config

  destination = Pathname.new(CONFIG['destination'])
  if destination.relative?
    destination = Pathname.new(File.expand_path(File.join(SOURCE_DIR, destination)))
  end

  Dir.chdir(destination.to_s) do
    print 'Starting serve...'
    ok_failed system("serve #{CONFIG['serve_port']} > /dev/null 2>&1 &")
  end
end

desc "stop all instances of serve"
task :stop_serve do
  require_config

  cmd = "ps auxw | awk '/bin\\/serve\\ #{CONFIG["serve_port"]}/ { print $2 }'"
  pid = `#{cmd}`.strip
  if pid.empty?
    puts "Serve is not running"
  else
    print "Stoping serve..."
    ok_failed system("kill -9 #{pid}")
  end
end

# TODO: Support SASS compiling through compass
desc 'Watch the site and regenerate when it changes'
task :watch do
  require_config

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
