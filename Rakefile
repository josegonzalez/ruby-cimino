require 'rubygems'
require 'bundler'
require 'yaml'

# Require all base rake tasks
require File.join(File.dirname(__FILE__), '_rake', 'deploy')
require File.join(File.dirname(__FILE__), '_rake', 'generate')
require File.join(File.dirname(__FILE__), '_rake', 'helper')
require File.join(File.dirname(__FILE__), '_rake', 'new')
require File.join(File.dirname(__FILE__), '_rake', 'serve')
require File.join(File.dirname(__FILE__), '_rake', 'setup')

# Constants
BASE_DIR = File.dirname(__FILE__)
SOURCE_DIR = File.join(BASE_DIR, ENV.fetch('source', 'source'))
CONFIG_FILE = File.join(SOURCE_DIR, '_config.yml')
CONFIG = YAML.load_file(CONFIG_FILE) if File.exists?(CONFIG_FILE)

# Ensure all directories exist
[ '', 'pygments_code', 'stash' ].each do |dir|
  FileUtils.mkdir_p(File.join(BASE_DIR, '_tmp', dir))
end

task :default => :dev
