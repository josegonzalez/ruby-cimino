require 'erb'
require 'tilt'
require 'clipboard'

###################
# Helper Methods  #
###################

def regenerate_site(relative)
  puts "\n\n>>> Change Detected to: #{relative} <<<"
  IO.popen('rake generate'){|io| print(io.readpartial(512)) until io.eof?}
  puts '>>> Update Complete <<<'
end

def ok_failed(condition)
  puts condition ? "OK" : "FAILED"
end

def ask?(message)
  print "#{message}\n[Y/n] "
  STDIN.gets.strip.downcase[0] == 'y'
end

def what_is(something, default)
  message = "What is #{something}?\n"
  message += "[#{default}] > " unless default.nil?
  print message

  it_is = STDIN.gets.strip
  it_is = default if it_is.empty?
end

def require_config
  raise "You must have a cimino install, please run `rake setup`" if !defined? CONFIG
end

def create_file(file, template, data)
  if File.exists?(file) && !ask?("#{file} already exists. Overwrite?")
    puts "Aborting creation of #{file}"
    return false
  end

  # Create the Template
  template_path = "#{SOURCE_DIR}/_templates/#{template}.erb"
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
  if CONFIG["editor"]
    puts "Opening file in editor using #{CONFIG['editor']}"
    system "#{CONFIG["editor"]} #{file}"
  else
    puts "Copying path to clipboard"
    Clipboard.copy file
  end

  return true
end
