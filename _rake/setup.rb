require 'date'

desc 'Setup a new install of cimino'
task :setup do
  # Ensure all directories exist
  puts "## Creating directories"
  [ SOURCE_DIR, File.join(SOURCE_DIR, '_posts') ].each do |dir|
    puts " - #{dir}"
    FileUtils.mkdir_p(dir)
  end

  # load config, suppress warnings
  data = {
    'title'       => what_is('the title of your blog', 'Jekyll Blog'),
    'author'      => what_is('the name you want to use on your blog', 'Drew Cimino'),
    'email'       => what_is('the public email people can use to contact you', 'mail@example.dev'),
    'source'      => what_is('the subdirectory where you will have your blog', 'source'),
    'destination' => what_is('the subdirectory where you will generate your blog to', '_site'),
  }

  config_file = File.join(BASE_DIR, data['source'], '_config.yml')

  if File.exists?(config_file) && !ask?("#{config_file} already exists. Overwrite?")
    puts "Aborting creation of #{config_file}"
    next
  end

  # Create the Template
  template_path = "#{SOURCE_DIR}/_templates/_config.erb"
  template_path = "./_templates/_config.erb" if !File.exists?(template_path)
  if !File.exists?(template_path)
    puts "Template '#{template}' does not exist!"
    next
  end

  template = Tilt.new(template_path)
  FileUtils.mkpath(File.dirname(config_file))
  File.open(config_file, 'w') {|f| f.write(template.render(Object.new, :data => data)) }
  CONFIG = YAML.load_file(config_file) if File.exists?(config_file)

  unless defined? CONFIG
    puts 'Unable to create the _config.yml file. Oops? Exiting'
    next
  end

  unless ask?('Create a new blog post?')
    puts 'No new post will be created. We\'ve created your blog, so get cracking!'
    next
  end

  post_name = what_is('the name of your post')
  if post_name.nil?
    puts 'No new post will be created. We\'ve created your blog, so get cracking!'
    next
  end

  data = { 'title' => post_name }
  [ 'category', 'comments', 'sharing'].each { |k| data[k] = CONFIG[k] if ENV.key?(k) }
  [ 'category', 'comments', 'sharing'].each { |k| data[k] = ENV[k] if ENV.key?(k) }
  [ 'category', 'comments', 'sharing'].each { |k| data[k] = true if !data.key?(k) }

  slug = "#{Date.today}-#{post_name.downcase.gsub(/[^\w]+/, '-')}"
  file = File.join(SOURCE_DIR, '_posts', "#{slug}.#{CONFIG['format']}")

  if create_file(file, 'post', data)
    puts 'Have fun blogging!'
  else
    puts 'Unable to create the post, oops...'
  end
end
