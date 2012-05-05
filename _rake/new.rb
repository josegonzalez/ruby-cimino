require 'date'

# TODO: Figure out a better way to hack the exit process of Rakefiles
desc "Begin a new post in _posts"
task :new_post do
  require_config

  unless ARGV.length > 1
    puts "USAGE: rake new_post 'the post title'"
    exit(1)
  end

  data = { 'title' => ARGV[1] }
  [ 'category', 'comments', 'sharing'].each { |k| data[k] = CONFIG[k] if CONFIG.key?(k) }
  [ 'category', 'comments', 'sharing'].each { |k| data[k] = ENV[k] if ENV.key?(k) }
  [ 'category', 'comments', 'sharing'].each { |k| data[k] = true if !data.key?(k) }

  slug = "#{Date.today}-#{ARGV[1].downcase.gsub(/[^\w]+/, '-')}"
  file = File.join(BASE_DIR, SOURCE_DIR, '_posts', "#{slug}.#{CONFIG['format']}")

  created = create_file(file, 'post', data)
  exit(created ? 0 : 1)
end

desc "Create a new page in (filename)/index.format"
task :new_page do
  require_config

  unless ARGV.length > 1
    puts "USAGE: rake new_page 'the post title'"
    exit(1)
  end

  data = { 'title' => ARGV[1] }
  [ 'comments', 'sharing'].each { |k| data[k] = CONFIG[k] if CONFIG.key?(k) }
  [ 'comments', 'sharing'].each { |k| data[k] = ENV[k] if ENV.key?(k) }
  [ 'comments', 'sharing'].each { |k| data[k] = true if !data.key?(k) }

  slug = "#{ARGV[1].downcase.gsub(/[^\w]+/, '-')}"
  file = File.join(BASE_DIR, SOURCE_DIR, slug, "index.#{CONFIG['format']}")

  created = create_file(file, 'page', data)
  exit(created ? 0 : 1)
end
